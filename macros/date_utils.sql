{% macro get_date_dimension_columns() %}
    {# 
        Returns a list of common date dimension columns that can be used in models.
        Usage: {{ get_date_dimension_columns() }}
    #}
    {% set date_columns = [
        'date_id',
        'date',
        'year',
        'quarter',
        'month',
        'week',
        'day_of_week',
        'day_of_month',
        'day_of_year',
        'is_weekend',
        'is_month_end',
        'is_quarter_end',
        'is_year_end'
    ] %}
    {{ return(date_columns) }}
{% endmacro %}

{% macro format_date_column(date_column, format='YYYY-MM-DD') %}
    {# 
        Formats a date column to a specific format.
        Usage: {{ format_date_column('created_at', 'YYYY-MM-DD') }}
    #}
    {% if target.type == 'postgres' %}
        to_char({{ date_column }}, '{{ format }}')
    {% elif target.type == 'snowflake' %}
        to_varchar({{ date_column }}, '{{ format }}')
    {% elif target.type == 'bigquery' %}
        format_date('{{ format }}', {{ date_column }})
    {% else %}
        {{ date_column }}
    {% endif %}
{% endmacro %}

{% macro get_date_range(start_date, end_date, interval='day') %}
    {# 
        Generates a date range between two dates.
        Usage: {{ get_date_range("'2023-01-01'", "'2023-12-31'", 'month') }}
    #}
    {% if target.type == 'postgres' %}
        generate_series(
            {{ start_date }}::date,
            {{ end_date }}::date,
            '1 {{ interval }}'::interval
        ) as date_range
    {% elif target.type == 'snowflake' %}
        date_range(
            {{ start_date }},
            {{ end_date }},
            '{{ interval }}'
        ) as date_range
    {% elif target.type == 'bigquery' %}
        generate_date_array(
            {{ start_date }},
            {{ end_date }},
            interval 1 {{ interval }}
        ) as date_range
    {% else %}
        {{ exceptions.raise_compiler_error("Database type " ~ target.type ~ " not supported") }}
    {% endif %}
{% endmacro %}

{% macro is_business_day(date_column) %}
    {# 
        Checks if a date is a business day (Monday-Friday).
        Usage: {{ is_business_day('order_date') }}
    #}
    {% if target.type == 'postgres' %}
        extract(dow from {{ date_column }}) not in (0, 6)
    {% elif target.type == 'snowflake' %}
        dayofweek(try_cast({{ date_column }} as date)) not in (1, 7)
    {% elif target.type == 'bigquery' %}
        extract(dayofweek from {{ date_column }}) not in (1, 7)
    {% else %}
        {{ exceptions.raise_compiler_error("Database type " ~ target.type ~ " not supported") }}
    {% endif %}
{% endmacro %}

{% macro get_fiscal_year_start(date_column, fiscal_year_start_month=7) %}
    {# 
        Gets the start of the fiscal year for a given date.
        Usage: {{ get_fiscal_year_start('transaction_date', 7) }}
    #}
    {% if target.type == 'postgres' %}
        case 
            when extract(month from {{ date_column }}) >= {{ fiscal_year_start_month }}
            then date_trunc('year', {{ date_column }} + interval '{{ 12 - fiscal_year_start_month }} months')
            else date_trunc('year', {{ date_column }} - interval '{{ fiscal_year_start_month - 1 }} months')
        end
    {% elif target.type == 'snowflake' %}
        date_trunc('year', dateadd(month, {{ 12 - fiscal_year_start_month }}, {{ date_column }}))
    {% elif target.type == 'bigquery' %}
        date_trunc(date_add({{ date_column }}, interval {{ 12 - fiscal_year_start_month }} month), year)
    {% else %}
        {{ exceptions.raise_compiler_error("Database type " ~ target.type ~ " not supported") }}
    {% endif %}
{% endmacro %} 