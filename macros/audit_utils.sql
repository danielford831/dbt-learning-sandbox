{% macro add_audit_columns() %}
    {# 
        Adds standard audit columns to a model.
        Usage: {{ add_audit_columns() }}
    #}
    current_timestamp as dbt_updated_at,
    '{{ invocation_id }}' as dbt_run_id,
    '{{ this }}' as dbt_model_name
{% endmacro %}

{% macro get_model_dependencies() %}
    {# 
        Returns a list of model dependencies for documentation.
        Usage: {{ get_model_dependencies() }}
    #}
    {% set dependencies = [] %}
    {% for node in graph.nodes.values() %}
        {% if node.resource_type == 'model' and node.depends_on.nodes %}
            {% set dependencies = dependencies + [node.name] %}
        {% endif %}
    {% endfor %}
    {{ return(dependencies) }}
{% endmacro %}

{% macro log_model_execution(model_name) %}
    {# 
        Logs model execution for tracking purposes.
        Usage: {{ log_model_execution('my_model') }}
    #}
    {% set log_query %}
        insert into {{ ref('dbt_execution_log') }} (
            model_name,
            execution_time,
            run_id,
            status
        ) values (
            '{{ model_name }}',
            current_timestamp,
            '{{ invocation_id }}',
            '{{ run_started_at }}'
        )
    {% endset %}
    {{ log_query }}
{% endmacro %}

{% macro validate_data_quality(table_name, column_name, validation_type='not_null') %}
    {# 
        Validates data quality for a specific column.
        Usage: {{ validate_data_quality('customers', 'email', 'not_null') }}
    #}
    {% if validation_type == 'not_null' %}
        select count(*) as failed_rows
        from {{ ref(table_name) }}
        where {{ column_name }} is null
    {% elif validation_type == 'unique' %}
        select count(*) as failed_rows
        from (
            select {{ column_name }}, count(*) as cnt
            from {{ ref(table_name) }}
            group by {{ column_name }}
            having count(*) > 1
        ) duplicates
    {% elif validation_type == 'accepted_values' %}
        -- This would need to be customized based on your specific validation rules
        select count(*) as failed_rows
        from {{ ref(table_name) }}
        where {{ column_name }} not in ('value1', 'value2', 'value3')
    {% else %}
        {{ exceptions.raise_compiler_error("Validation type " ~ validation_type ~ " not supported") }}
    {% endif %}
{% endmacro %}

{% macro get_table_row_count(table_name) %}
    {# 
        Gets the row count for a table.
        Usage: {{ get_table_row_count('customers') }}
    #}
    select count(*) as row_count
    from {{ ref(table_name) }}
{% endmacro %}

{% macro compare_table_sizes(table1, table2) %}
    {# 
        Compares the sizes of two tables.
        Usage: {{ compare_table_sizes('customers_staging', 'customers') }}
    #}
    select 
        '{{ table1 }}' as table_name,
        count(*) as row_count
    from {{ ref(table1) }}
    
    union all
    
    select 
        '{{ table2 }}' as table_name,
        count(*) as row_count
    from {{ ref(table2) }}
{% endmacro %} 