--------------------------------------------------------
--  DDL for Package PQP_UPDATE_WORK_PATTERN_TABLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UPDATE_WORK_PATTERN_TABLE" AUTHID CURRENT_USER AS
/* $Header: pquwprow.pkh 120.0 2005/05/29 02:15 appldev noship $ */

TYPE rec_rows_details IS RECORD(
 --row_name                   pay_user_rows_f.row_low_range_or_name%TYPE
  user_row_id                pay_user_rows_f.user_row_id%TYPE
 ,effective_start_date       DATE
 ,effective_end_date         DATE );

TYPE t_row_details IS TABLE OF rec_rows_details
INDEX BY BINARY_INTEGER;

TYPE t_row_ids IS TABLE OF pay_user_rows_f.user_row_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_row_names IS TABLE OF pay_user_rows_f.row_low_range_or_name%TYPE
INDEX BY BINARY_INTEGER;

TYPE t_row_values IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;




CURSOR csr_get_value (
       p_user_column_id    IN NUMBER
      ,p_user_row_id       IN NUMBER
      ,p_effective_date    IN DATE
      ,p_business_group_id IN NUMBER
      ,p_legislation_code  IN VARCHAR2
     ) IS
SELECT puci.value value
      ,puci.user_column_instance_id user_column_instance_id
      ,puci.rowid row_id
      ,puci.effective_start_date effective_start_date
      ,puci.effective_end_date effective_end_date
FROM   pay_user_column_instances_f puci
WHERE  ( puci.business_group_id   = p_business_group_id
        OR puci.legislation_code = p_legislation_code )
  AND  puci.user_column_id      = p_user_column_id
  AND  puci.user_row_id         = p_user_row_id;
  --AND  p_effective_date BETWEEN puci.effective_start_date
    --                        AND puci.effective_end_date ;
--commented out the above code as per the multiple entries in the
--Columns of the 'PQP_COMAPNY WORK_PATTERNS'issue raised in the Bug# 4078709


PROCEDURE update_working_days_in_week (
          errbuf                OUT NOCOPY  VARCHAR2
         ,retcode               OUT NOCOPY  NUMBER
         ,p_column_name         IN  VARCHAR2
         ,p_business_group_id   IN  NUMBER
         ,p_overwrite_if_exists IN  VARCHAR2
  );

FUNCTION get_avg_working_days_in_week (
         p_business_group_id          IN  NUMBER
        ,p_effective_date             IN  DATE
        ,p_user_column_id             IN  pay_user_columns.user_column_id%TYPE
        ,p_user_table_id              IN  pay_user_tables.user_table_id%TYPE
        ,p_total_days_defined         OUT NOCOPY  NUMBER
        ,p_total_working_days_defined OUT NOCOPY  NUMBER
  ) RETURN NUMBER  ;

 PROCEDURE update_insert_row(
           p_user_column_id           IN NUMBER
          ,p_user_row_id              IN NUMBER
          ,p_effective_date           IN DATE
	  ,p_row_effective_start_date IN DATE
	  ,p_row_effective_end_date   IN DATE
	  ,p_business_group_id        IN NUMBER
	  ,p_value_to_update          IN NUMBER
          ,p_overwrite_if_exists      IN VARCHAR2
  ) ;


END pqp_update_work_pattern_table ;

 

/
