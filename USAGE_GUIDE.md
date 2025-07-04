# Usage Guide - Your Company Utils dbt Package

This guide provides step-by-step instructions for using the Your Company Utils dbt package in your projects.

## Quick Start

### 1. Install the Package

#### Option A: Local Development
```bash
# Clone the package repository
git clone https://github.com/your-company/your_company_utils.git
cd your_company_utils

# Run the installation script
./scripts/install_local.sh
```

#### Option B: From Git Repository
Add to your project's `packages.yml`:
```yaml
packages:
  - git: "https://github.com/your-company/your_company_utils.git"
    revision: main  # or specific tag/commit
```

### 2. Install Dependencies
```bash
dbt deps
```

### 3. Test the Installation
```bash
dbt run --select your_company_utils
dbt test --select your_company_utils
```

## Detailed Usage Examples

### Date Utilities

#### Creating a Date Dimension
```sql
-- models/dim_date.sql
with date_range as (
    {{ get_date_range("'2020-01-01'", "'2030-12-31'", 'day') }}
)

select
    date_range as date_id,
    extract(year from date_range) as year,
    extract(month from date_range) as month,
    {{ is_business_day('date_range') }} as is_business_day,
    {{ format_date_column('date_range', 'YYYY-MM-DD') }} as formatted_date
from date_range
```

#### Working with Business Days
```sql
-- models/orders_business_days.sql
select
    order_id,
    order_date,
    {{ is_business_day('order_date') }} as is_business_day,
    case 
        when {{ is_business_day('order_date') }} then 'Business Day'
        else 'Weekend'
    end as day_type
from {{ ref('orders') }}
```

#### Fiscal Year Calculations
```sql
-- models/revenue_fiscal_year.sql
select
    transaction_date,
    revenue,
    {{ get_fiscal_year_start('transaction_date', 7) }} as fiscal_year_start,
    extract(year from {{ get_fiscal_year_start('transaction_date', 7) }}) as fiscal_year
from {{ ref('transactions') }}
```

### String Utilities

#### Cleaning Customer Data
```sql
-- models/customers_clean.sql
select
    customer_id,
    {{ clean_string_column('customer_name') }} as clean_name,
    {{ clean_string_column('email') }} as clean_email,
    {{ extract_email_domain('email') }} as email_domain,
    {{ is_valid_email('email') }} as valid_email
from {{ ref('customers_staging') }}
```

#### Data Masking for Privacy
```sql
-- models/customers_anonymized.sql
select
    customer_id,
    {{ mask_sensitive_data('email', 'email') }} as masked_email,
    {{ mask_sensitive_data('phone_number', 'phone') }} as masked_phone,
    {{ generate_slug('customer_name') }} as customer_slug
from {{ ref('customers') }}
```

### Audit Utilities

#### Adding Audit Columns
```sql
-- models/any_model_with_audit.sql
select
    *,
    {{ add_audit_columns() }}
from {{ ref('source_table') }}
```

#### Data Quality Validation
```sql
-- models/data_quality_checks.sql
with email_validation as (
    {{ validate_data_quality('customers', 'email', 'not_null') }}
),
unique_customer_check as (
    {{ validate_data_quality('customers', 'customer_id', 'unique') }}
)

select * from email_validation
union all
select * from unique_customer_check
```

#### Table Size Monitoring
```sql
-- models/table_monitoring.sql
{{ compare_table_sizes('customers_staging', 'customers') }}
```

## Advanced Usage

### Custom Macro Development

#### Creating Your Own Macros
```sql
-- macros/custom_utils.sql
{% macro calculate_customer_lifetime_value(customer_id, start_date, end_date) %}
    select
        {{ customer_id }},
        sum(revenue) as lifetime_value,
        count(distinct order_id) as total_orders,
        avg(revenue) as avg_order_value
    from {{ ref('orders') }}
    where customer_id = {{ customer_id }}
    and order_date between {{ start_date }} and {{ end_date }}
{% endmacro %}
```

#### Using Macros in Models
```sql
-- models/customer_analytics.sql
with customer_metrics as (
    {{ calculate_customer_lifetime_value('customer_id', "'2023-01-01'", "'2023-12-31'") }}
)

select * from customer_metrics
```

### Testing Your Macros

#### Creating Custom Tests
```sql
-- tests/test_custom_macro.sql
-- Test that the custom macro returns expected results
select count(*) as failed_rows
from (
    {{ calculate_customer_lifetime_value(1, "'2023-01-01'", "'2023-12-31'") }}
) results
where lifetime_value < 0
```

## Best Practices

### 1. Macro Organization
- Group related macros in the same file
- Use descriptive file names
- Include comprehensive documentation

### 2. Error Handling
```sql
{% macro safe_divide(numerator, denominator) %}
    case 
        when {{ denominator }} = 0 then null
        else {{ numerator }} / {{ denominator }}
    end
{% endmacro %}
```

### 3. Performance Considerations
- Use incremental models for large datasets
- Add appropriate indexes on frequently queried columns
- Consider materialization strategies

### 4. Documentation
```sql
{% macro well_documented_macro(param1, param2='default') %}
    {# 
        This macro does something useful.
        
        Args:
            param1: Description of param1
            param2: Description of param2 (optional)
            
        Returns:
            Description of what the macro returns
            
        Example:
            {{ well_documented_macro('value1', 'value2') }}
    #}
    -- Macro implementation here
{% endmacro %}
```

## Troubleshooting

### Common Issues

#### 1. Macro Not Found
**Error**: `Compilation Error: macro 'your_macro' not found`

**Solution**: 
- Ensure the package is properly installed: `dbt deps`
- Check that the macro file is in the `macros/` directory
- Verify the macro name spelling

#### 2. Database Compatibility
**Error**: `Database type not supported`

**Solution**:
- Check that your target database is supported (PostgreSQL, Snowflake, BigQuery)
- Update the macro to include your database type

#### 3. Profile Configuration
**Error**: `Profile not found`

**Solution**:
- Ensure your `profiles.yml` is properly configured
- Check that the profile name matches your `dbt_project.yml`

### Debugging Tips

#### 1. Check Macro Compilation
```bash
dbt compile --select your_model
```

#### 2. View Generated SQL
```bash
dbt compile --select your_model --output path/to/output.sql
```

#### 3. Test Individual Macros
```bash
dbt run-operation your_macro --args '{param1: "value1"}'
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: dbt CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dbt
        run: pip install dbt-core dbt-postgres
      - name: Install dependencies
        run: dbt deps
      - name: Run tests
        run: dbt test
      - name: Run models
        run: dbt run
```

## Support and Contributing

### Getting Help
1. Check the documentation in the README.md
2. Review the macro comments for usage examples
3. Create an issue in the repository

### Contributing
1. Fork the repository
2. Create a feature branch
3. Add your improvements
4. Include tests and documentation
5. Submit a pull request

### Version Compatibility
- This package is compatible with dbt Core 1.0.0+
- Test with your specific dbt version before deploying to production 