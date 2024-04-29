--------------------------------------------------------
--  DDL for Package PAY_NO_TAX_TABLE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_TAX_TABLE_UPLOAD" 
/* $Header: pynottup.pkh 120.0.12000000.1 2007/01/17 23:14:22 appldev noship $ */
AUTHID CURRENT_USER AS

PROCEDURE MAIN
(
errbuf                  OUT  nocopy  VARCHAR2,
retcode                 OUT  nocopy  NUMBER,
p_data_file_name         IN          VARCHAR2,
p_effective_start_date   IN          VARCHAR2,
p_business_group         IN          NUMBER
);


PROCEDURE PURGE(
errbuf                   OUT  nocopy VARCHAR2,
retcode                  OUT  nocopy NUMBER,
p_business_group       IN  NUMBER,
p_effective_start_date   IN   VARCHAR2,
p_effective_end_date     IN   VARCHAR2
);

PROCEDURE check_date
(
p_effective_start_date   IN   varchar2,
p_effective_end_date     IN   varchar2,
p_message_name           IN   varchar2
);


PROCEDURE Upload_Tax_To_Temp_Table
(
errbuf          OUT nocopy VARCHAR2,
retcode         OUT nocopy  NUMBER,
p_data_file_name IN  VARCHAR2
);

PROCEDURE Upload_Tax_To_Main_Table
(
errbuf             OUT  nocopy VARCHAR2,
retcode            OUT  nocopy NUMBER,
p_legislation_code     IN  VARCHAR2,
p_effective_start_date IN  DATE,
p_business_group       IN  NUMBER
);


PROCEDURE split_line
(
p_line             IN  VARCHAR2
,p_RANGE_TABLE_NUMBER   OUT nocopy PAY_RANGE_TABLES_F .RANGE_TABLE_NUMBER%TYPE
,p_EARNINGS_TYPE        out nocopy PAY_RANGE_TABLES_F .EARNINGS_TYPE%TYPE
,p_PERIOD_FREQUENCY     OUT nocopy PAY_RANGE_TABLES_F .PERIOD_FREQUENCY%TYPE
,p_LOW_BAND             OUT nocopy PAY_RANGES_F.LOW_BAND%TYPE
,p_AMOUNT1              OUT nocopy PAY_RANGES_F.AMOUNT1%TYPE
);



PROCEDURE END_DATE_CHILD
(
p_Range_Table_id in Number
,p_effective_start_date in DATE
);
END pay_no_tax_table_upload;

 

/
