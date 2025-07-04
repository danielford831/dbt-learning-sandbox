# Your Company Utils - dbt Package

A comprehensive dbt package containing shared utilities and macros for your company's data transformation needs.

## Overview

This package provides a collection of reusable macros, models, and utilities that can be shared across multiple dbt projects within your organization. It includes:

- **Date Utilities**: Common date manipulation and formatting functions
- **String Utilities**: String cleaning, validation, and transformation functions
- **Audit Utilities**: Data lineage tracking and quality validation functions
- **Example Models**: Demonstrations of how to use the utilities

## Installation

### Local Development

To use this package locally during development:

1. Clone this repository to your local machine
2. In your main dbt project's `packages.yml`, add:

```yaml
packages:
  - local:
      path: ../path/to/your_company_utils
```

### Production Deployment

For production use, you can:

1. **Host on GitHub/GitLab**: Reference the package directly from your repository
2. **Use dbt Hub**: Publish to dbt Hub for public access
3. **Private Package Registry**: Set up a private package registry

Example `packages.yml` for GitHub:
```yaml
packages:
  - git: "https://github.com/your-company/your_company_utils.git"
    revision: main  # or specific tag/commit
```

## Available Macros

### Date Utilities (`macros/date_utils.sql`)

- `get_date_dimension_columns()`: Returns list of common date dimension columns
- `format_date_column(date_column, format)`: Formats dates consistently across databases
- `get_date_range(start_date, end_date, interval)`: Generates date ranges
- `is_business_day(date_column)`: Checks if a date is a business day
- `get_fiscal_year_start(date_column, fiscal_year_start_month)`: Calculates fiscal year start

### String Utilities (`macros/string_utils.sql`)

- `clean_string_column(string_column)`: Removes extra whitespace and normalizes strings
- `extract_email_domain(email_column)`: Extracts domain from email addresses
- `mask_sensitive_data(column_name, mask_type)`: Masks sensitive data (emails, phones)
- `generate_slug(text_column)`: Creates URL-friendly slugs
- `is_valid_email(email_column)`: Validates email format

### Audit Utilities (`macros/audit_utils.sql`)

- `add_audit_columns()`: Adds standard audit columns to models
- `get_model_dependencies()`: Returns model dependency information
- `log_model_execution(model_name)`: Logs model execution for tracking
- `validate_data_quality(table_name, column_name, validation_type)`: Data quality validation
- `get_table_row_count(table_name)`: Gets row count for tables
- `compare_table_sizes(table1, table2)`: Compares table sizes

## Example Models

### Date Dimension (`models/example/date_dimension.sql`)

A comprehensive date dimension table that demonstrates:
- Date range generation
- Business day calculations
- Fiscal year handling
- Audit column addition

### Customer Clean (`models/example/customer_clean.sql`)

A customer data cleaning model that demonstrates:
- String cleaning and normalization
- Email validation and domain extraction
- Data masking for privacy
- Slug generation

## Usage Examples

### In Your Models

```sql
-- Using date utilities
select
    order_date,
    {{ is_business_day('order_date') }} as is_business_day,
    {{ format_date_column('order_date', 'YYYY-MM-DD') }} as formatted_date
from {{ ref('orders') }}

-- Using string utilities
select
    customer_name,
    {{ clean_string_column('customer_name') }} as clean_name,
    {{ extract_email_domain('email') }} as email_domain,
    {{ is_valid_email('email') }} as valid_email
from {{ ref('customers') }}

-- Using audit utilities
select
    *,
    {{ add_audit_columns() }}
from {{ ref('staging_table') }}
```

### In Your Tests

```sql
-- Test data quality
{{ validate_data_quality('customers', 'email', 'not_null') }}

-- Compare table sizes
{{ compare_table_sizes('staging_customers', 'customers') }}
```

## Database Support

This package supports multiple database types:
- **PostgreSQL**
- **Snowflake**
- **BigQuery**

The macros automatically detect the target database type and use the appropriate SQL syntax.

## Configuration

### Profile Setup

Update the `profiles.yml` file with your database connection details:

```yaml
your_company_utils:
  target: dev
  outputs:
    dev:
      type: postgres  # or snowflake, bigquery
      host: localhost
      user: your_username
      password: your_password
      port: 5432
      dbname: your_database
      schema: your_schema
```

### Package Dependencies

The package includes common dependencies in `packages.yml`:
- `dbt-labs/codegen`: For generating model code
- `dbt-labs/dbt_utils`: Additional utility functions

## Development

### Adding New Macros

1. Create a new `.sql` file in the `macros/` directory
2. Add comprehensive documentation in the macro comments
3. Include usage examples
4. Add tests in the `tests/` directory

### Testing

Run tests to ensure everything works correctly:

```bash
dbt test
```

### Documentation

Generate documentation:

```bash
dbt docs generate
dbt docs serve
```

## Contributing

1. Create a feature branch
2. Add your new utilities or improvements
3. Include tests and documentation
4. Submit a pull request

## Versioning

This package follows semantic versioning. Update the version in `dbt_packages.yml` when making changes:

- **Patch** (0.1.x): Bug fixes and minor improvements
- **Minor** (0.x.0): New features, backward compatible
- **Major** (x.0.0): Breaking changes

## License

[Add your license information here]

## Support

For questions or issues, please contact your data team or create an issue in the repository. 