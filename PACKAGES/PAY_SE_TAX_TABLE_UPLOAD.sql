--------------------------------------------------------
--  DDL for Package PAY_SE_TAX_TABLE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_TAX_TABLE_UPLOAD" 
/* $Header: pysettup.pkh 120.2 2007/02/15 17:58:33 vetsrini noship $ */
AUTHID CURRENT_USER AS
   PROCEDURE main (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_data_file_name           IN       VARCHAR2
     ,p_tax_table_type           IN       VARCHAR2
     ,p_effective_start_date     IN       VARCHAR2
     ,p_business_group           IN       NUMBER
   );

   PROCEDURE PURGE (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_business_group           IN       NUMBER
     ,p_effective_start_date     IN       VARCHAR2
     ,p_effective_end_date       IN       VARCHAR2
   );

   PROCEDURE check_date (
      p_effective_start_date     IN       VARCHAR2
     ,p_effective_end_date       IN       VARCHAR2
     ,p_message_name             IN       VARCHAR2
   );

   PROCEDURE upload_tax_to_temp_table (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_data_file_name           IN       VARCHAR2
     ,p_tax_table_type           IN       VARCHAR2
   );

   PROCEDURE upload_tax_to_main_table (
      errbuf                     OUT NOCOPY VARCHAR2
     ,retcode                    OUT NOCOPY NUMBER
     ,p_legislation_code         IN       VARCHAR2
     ,p_effective_start_date     IN       DATE
     ,p_business_group           IN       NUMBER
     ,p_tax_table_type           IN       VARCHAR2
   );

   PROCEDURE split_line (
      p_line                     IN       VARCHAR2
     ,p_range_table_number       OUT NOCOPY pay_range_tables_f.range_table_number%TYPE
     ,p_row_value_uom            OUT NOCOPY pay_range_tables_f.row_value_uom%TYPE
     ,p_period_frequency         OUT NOCOPY pay_range_tables_f.period_frequency%TYPE
     ,p_low_band                 OUT NOCOPY pay_ranges_f.low_band%TYPE
     ,p_high_band                OUT NOCOPY pay_ranges_f.high_band%TYPE
     ,p_amount1                  OUT NOCOPY pay_ranges_f.amount1%TYPE
     ,p_amount2                  OUT NOCOPY pay_ranges_f.amount2%TYPE
     ,p_amount3                  OUT NOCOPY pay_ranges_f.amount3%TYPE
     ,p_amount4                  OUT NOCOPY pay_ranges_f.amount4%TYPE
     ,p_amount5                  OUT NOCOPY pay_ranges_f.amount5%TYPE
     ,p_amount6                  OUT NOCOPY pay_ranges_f.amount6%TYPE
     ,p_amount7                  OUT NOCOPY pay_ranges_f.amount7%TYPE
     ,p_amount8                  OUT NOCOPY pay_ranges_f.amount8%TYPE
   );

   PROCEDURE end_date_child (
      p_range_table_id           IN       NUMBER
     ,p_effective_start_date     IN       DATE
   );
END pay_se_tax_table_upload;

/
