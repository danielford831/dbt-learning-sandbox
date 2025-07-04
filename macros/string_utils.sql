{% macro clean_string_column(string_column) %}
    {# 
        Cleans a string column by removing extra whitespace and converting to proper case.
        Usage: {{ clean_string_column('customer_name') }}
    #}
    {% if target.type == 'postgres' %}
        trim(regexp_replace({{ string_column }}, '\s+', ' ', 'g'))
    {% elif target.type == 'snowflake' %}
        trim(regexp_replace({{ string_column }}, '\\s+', ' '))
    {% elif target.type == 'bigquery' %}
        trim(regexp_replace({{ string_column }}, r'\s+', ' '))
    {% else %}
        {{ string_column }}
    {% endif %}
{% endmacro %}

{% macro extract_email_domain(email_column) %}
    {# 
        Extracts the domain from an email address.
        Usage: {{ extract_email_domain('user_email') }}
    #}
    {% if target.type == 'postgres' %}
        split_part({{ email_column }}, '@', 2)
    {% elif target.type == 'snowflake' %}
        split_part({{ email_column }}, '@', 2)
    {% elif target.type == 'bigquery' %}
        split({{ email_column }}, '@')[offset(1)]
    {% else %}
        {{ exceptions.raise_compiler_error("Database type " ~ target.type ~ " not supported") }}
    {% endif %}
{% endmacro %}

{% macro mask_sensitive_data(column_name, mask_type='email') %}
    {# 
        Masks sensitive data like emails, phone numbers, or credit cards.
        Usage: {{ mask_sensitive_data('email', 'email') }}
    #}
    {% if mask_type == 'email' %}
        {% if target.type == 'postgres' %}
            regexp_replace({{ column_name }}, '([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', '***@\2')
        {% elif target.type == 'snowflake' %}
            regexp_replace({{ column_name }}, '([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})', '***@\\2')
        {% elif target.type == 'bigquery' %}
            regexp_replace({{ column_name }}, r'([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', '***@\\2')
        {% endif %}
    {% elif mask_type == 'phone' %}
        {% if target.type == 'postgres' %}
            regexp_replace({{ column_name }}, '(\d{3})(\d{3})(\d{4})', '***-***-\3')
        {% elif target.type == 'snowflake' %}
            regexp_replace({{ column_name }}, '(\\d{3})(\\d{3})(\\d{4})', '***-***-\\3')
        {% elif target.type == 'bigquery' %}
            regexp_replace({{ column_name }}, r'(\d{3})(\d{3})(\d{4})', '***-***-\\3')
        {% endif %}
    {% else %}
        {{ column_name }}
    {% endif %}
{% endmacro %}

{% macro generate_slug(text_column) %}
    {# 
        Generates a URL-friendly slug from a text column.
        Usage: {{ generate_slug('product_name') }}
    #}
    {% if target.type == 'postgres' %}
        lower(regexp_replace(regexp_replace({{ text_column }}, '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
    {% elif target.type == 'snowflake' %}
        lower(regexp_replace(regexp_replace({{ text_column }}, '[^a-zA-Z0-9\\s-]', ''), '\\s+', '-'))
    {% elif target.type == 'bigquery' %}
        lower(regexp_replace(regexp_replace({{ text_column }}, r'[^a-zA-Z0-9\s-]', ''), r'\s+', '-'))
    {% else %}
        {{ text_column }}
    {% endif %}
{% endmacro %}

{% macro is_valid_email(email_column) %}
    {# 
        Validates if a string is a valid email format.
        Usage: {{ is_valid_email('user_email') }}
    #}
    {% if target.type == 'postgres' %}
        {{ email_column }} ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    {% elif target.type == 'snowflake' %}
        regexp_like({{ email_column }}, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
    {% elif target.type == 'bigquery' %}
        regexp_contains({{ email_column }}, r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
    {% else %}
        {{ exceptions.raise_compiler_error("Database type " ~ target.type ~ " not supported") }}
    {% endif %}
{% endmacro %} 