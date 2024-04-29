--------------------------------------------------------
--  DDL for Package AR_GTA_TXT_OPERATOR_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_TXT_OPERATOR_PROC" AUTHID CURRENT_USER AS
----$Header: ARGRIETS.pls 120.0.12010000.3 2010/01/19 08:27:15 choli noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                      Redwood Shores, California, USA                      |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :                                                               |
--|      ARRIETS.pls                                                         |
--|                                                                           |
--|  DESCRIPTION:                                                             |
--|      This package consists of server procedures, which are used to        |
--|      export customers, items and invoice to flat files respectively,      |
--|      also there is a procedure to import data from GT through flat        |
--|      file                                                                 |
--|                                                                           |
--|                                                                           |
--|  HISTORY:                                                                 |
--|      05/12/2005     Jogen             Created                             |
--|      05/17/2005     Jim Zheng         Add procedure  Export_Customers     |
--|      05/17/2005     Donghai Wang      Add procedure  Export_Items         |
--|      08/25/2005     Jogen             Update invoice_import               |
--|                                     change Clear_Imp_Temp_Table to public |
--|      09/28/2005     Jogen             Update invoice_import due to TCA    |
--|                                       change                              |
--|      09/29/2005     Jim.Zheng         Update Customer Export, give up     |
--|                                       the tax_payer_id export             |
--|                                                                           |
--|      06/04/2006    Donghai Wang       Modify record type g_item_rec to    |
--|                                       remove tax_rate                     |
--|      10/12/2008    Lv Xiao            Modified for bug#7626503            |
--+===========================================================================+
TYPE COLUMN_VALUES IS TABLE OF VARCHAR2(200);
TYPE g_noreference_tbl IS TABLE OF mtl_system_items_b_kfv.concatenated_segments%TYPE
INDEX  BY BINARY_INTEGER;

TYPE g_item_rec IS RECORD(item_number     VARCHAR2(4000)
                         ,item_name       VARCHAR2(500)
                         ,tax_name        VARCHAR2(240)
                         ,item_model      VARCHAR2(240)
                         ,uom             VARCHAR2(25)
                         );

TYPE g_item_tbl IS TABLE OF g_item_rec
INDEX BY BINARY_INTEGER;

--add by Lv Xiao for bug#7626503 on 10-Dec-2008, begin
---------------------------------------------------------
--this cursor is to keep all the duplicated description record
TYPE draft_dup_record  IS RECORD
    (ra_trx_id    AR_GTA_TRX_HEADERS.ra_trx_id%TYPE,
     description  AR_GTA_TRX_HEADERS.description%TYPE,
     org_id        AR_GTA_TRX_HEADERS.org_id%TYPE,
     gta_trx_number AR_GTA_TRX_HEADERS.gta_trx_number%TYPE
    ) ;
TYPE crmemo_dup_cur_TYPE IS REF CURSOR RETURN draft_dup_record;

--this record is to keep all the dupliacted desription record
--that fatch from the cursor

TYPE dup_record  IS RECORD
    (ra_trx_id    AR_GTA_TRX_HEADERS.ra_trx_id%TYPE,
     description  AR_GTA_TRX_HEADERS.description%TYPE,
     org_id        AR_GTA_TRX_HEADERS.org_id%TYPE,
     gta_trx_number AR_GTA_TRX_HEADERS.gta_trx_number%TYPE
    ) ;
TYPE dup_record_tbl IS TABLE OF dup_record;
---------------------------------------------------------
--add by Lv Xiao for bug#7626503 on 10-Dec-2008, end


--==========================================================================
--  PROCEDURE NAME:
--
--    Put_Line                     Public
--
--  DESCRIPTION:
--
--      This procedure write data to log file.
--
--  PARAMETERS:
--      In: p_str         VARCHAR2
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Put_Line
( p_str                  IN        VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Put_Log                     Public
--
--  DESCRIPTION:
--
--      This procedure write data to log file.
--
--  PARAMETERS:
--      In:  p_str         VARCHAR2
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Put_Log
( p_str                  IN        VARCHAR2
);


--==========================================================================
--  PROCEDURE NAME:
--
--    Import_Invoices                     Public
--
--  DESCRIPTION:
--
--      This procedure import VAT invoices from flat file to GTA
--      Because SQL*Loader will import flat file to temporary table
--      AR_GTA_TRXIMP_TMP and GTA_TRX_NUMBER  is a unique column
--      in GTA, so no parameter is needed here
--
--  PARAMETERS:
--      In:  None
--     Out:  None
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Import_Invoices;

--==========================================================================
--  PROCEDURE NAME:
--
--    Clear_Imp_Temp_Table               Public
--
--  DESCRIPTION:
--
--      This procedure clear the data imported from flat file
--      in temporary table
--
--  PARAMETERS:
--      In:  None
--     Out:  None
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Clear_Imp_Temp_Table;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_From_Conc                    Public
--
--  DESCRIPTION:
--
--      This procedure will export GTA invoices to the flat file
--      Its output will be printed on concurrent output and will
--      be save as flat file by users.
--
--  PARAMETERS:
--      In:  p_org_id                  Identifier of operation unit
--           p_regeneration            New batch('N') or regeneration('Y')
--	     p_FP_Tax_reg_Number       The first party tax registration number
--           p_transfer_rule_id        GTA transfer rule header ID
--           p_batch_number            Export batch number
--           p_customer_id_from_number AccountID against customer Number
--           p_customer_id_from_name   AccountID against customer Name
--           p_cust_id_from_taxpayer   AccountID against taxpayerid
--           p_ar_trx_num_from         AR transaction Number
--           p_ar_trx_num_to           AR transaction Number
--           p_ar_trx_date_from        AR transaction date
--           p_ar_trx_date_to          AR transaction date
--           p_ar_trx_gl_date_from     AR transaction GL date
--           p_ar_trx_gl_date_to       AR transaction GL date
--           p_ar_trx_batch_from       AR transaction batch name
--           p_ar_trx_batch_to         AR transaction batch name
--           p_trx_class               AR transaction class: INV, CM, DM
--           P_Batch_ID                GTA batch number
--           P_Invoice_Type_ID         Invoice Type
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--	    09/29/05       Jogen Hu      add parameter p_FP_Tax_reg_Number
--                                       due to TCA change
--      01/02/08       Subba         add parameter p_Invoice_Type_ID
--===========================================================================
PROCEDURE Export_Invoices_From_Conc
( p_org_id                  IN       NUMBER
, p_regeneration            IN       VARCHAR2
, p_FP_Tax_reg_Number       IN       VARCHAR2
, p_transfer_rule_id        IN       NUMBER
, p_batch_number            IN       VARCHAR2
, p_customer_id_from_number IN       NUMBER
, p_customer_id_from_name   IN       NUMBER
, p_cust_id_from_taxpayer   IN       NUMBER
, p_ar_trx_num_from         IN       VARCHAR2
, p_ar_trx_num_to           IN       VARCHAR2
, p_ar_trx_date_from        IN       DATE
, p_ar_trx_date_to          IN       DATE
, p_ar_trx_gl_date_from     IN       DATE
, p_ar_trx_gl_date_to       IN       DATE
, p_ar_trx_batch_from       IN       VARCHAR2
, p_ar_trx_batch_to         IN       VARCHAR2
, p_trx_class               IN       VARCHAR2
, p_batch_id                IN       VARCHAR2
, p_invoice_type_id         IN       VARCHAR2
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Invoices_From_Workbench                     Public
--
--  DESCRIPTION:
--
--      This procedure export VAT invoices from GTA to flat file
--      and is invoked in workbench.
--
--  PARAMETERS:
--      In:  p_org_id            Identifier of operating unit
--           p_generator_id      Indicate which need export(choose in workbench)
--           P_Batch_ID          export batch number
--
--     Out:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.docexport_invoices_from_workbench
--
--  CHANGE HISTORY:
--
--      05/12/05       Jogen Hu      Created
--===========================================================================
PROCEDURE Export_Invoices_From_Workbench
( p_org_id                 IN       NUMBER
, p_generator_id           IN       NUMBER
, p_batch_id               IN       VARCHAR2
);

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Trx_Class                     Public
--
--  DESCRIPTION:
--
--      This procedure get transaction class
--
--  PARAMETERS:
--      In:  p_GTA_org_id       GTA transaction org id
--      In:  p_GTA_trx_id       GTA transaction id
--
--     Out:
--  Return:  VARCHAR2;
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    09/12/08       Lv Xiao      Created
--===========================================================================
FUNCTION Get_Trx_Class
( p_gta_org_id         IN       NUMBER
, p_gta_trx_id         IN       NUMBER
)RETURN VARCHAR2;


--==========================================================================
--  FUNCTION NAME:
--
--    Check_Header                 Public
--
--  DESCRIPTION:
--
--      This procedure check whether the columns of export data
--      exceeding Golden Tax required length.
--
--  PARAMETERS:
--      In:    p_gta_trx_header      GTA transaction header
--     Out:
--  Return:    PLS_INTEGER
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
FUNCTION Check_Header
( p_gta_trx_header         IN       AR_GTA_TRX_UTIL.TRX_HEADER_REC_TYPE
)RETURN PLS_INTEGER;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Line_Length                     Public
--
--  DESCRIPTION:
--
--      This procedure check whether the columns of export data
--      exceeding Golden Tax required length
--
--  PARAMETERS:
--      In:  p_gta_trx_line      GTA transaction line record
--
--     Out:
--  Return:  BOOLEAN;
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--	    05/12/05       Jogen Hu      Created
--===========================================================================
FUNCTION Check_Line_Length
( p_gta_trx_line           IN       AR_GTA_TRX_UTIL.TRX_LINE_REC_TYPE
)RETURN BOOLEAN;

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Customers                     Public
--
--  DESCRIPTION:
--
--      This procedure export customers information  from GTA to flat file
--
--  PARAMETERS:
--      In:   p_org_id                 Identifier of operating unit
--            p_customer_num_from      Customer number low range
--            p_customer_num_to        Customer number high range
--            p_customer_name_from     Customer name low range
--            p_customer_name_to       Customer name high range
--            p_taxpayee_id            Identifier of taxpayer
--            p_creation_date_from     Creation date low range
--            p_creation_date_to       Creation date high range
--
--     OUt:
--
--  DESIGN REFERENCES:
--      GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           06/05/05      Jim Zheng   Created
--           30/09/05      Jim Zheng   updated  delete the export of tax_payer_id
--
--===========================================================================
PROCEDURE Export_Customers
( p_org_id               IN NUMBER
, p_customer_num_from    IN VARCHAR2
, p_customer_num_to      IN VARCHAR2
, p_customer_name_from   IN VARCHAR2
, p_customer_name_to     IN VARCHAR2
--, p_taxpayee_id          IN VARCHAR2
, p_creation_date_from   IN DATE
, p_creation_date_to     IN DATE
);

--==========================================================================
--  PROCEDURE NAME:
--
--    Export_Items            Public
--
--  DESCRIPTION:
--
--    This procedure is to export item information from
--    inventory to a flat file with special format, the flat
--    will be used as import file to import items into GT system
--
--  PARAMETERS:
--      In:  p_org_id                 Identifier for Operating Unit
--           p_master_org_id          Identifier for Master Organization
--                                    of inventory organization
--           p_item_num_from          High range of item number
--           p_item_num_to            Low range of item number
--           p_category_set_id        Identifier of item category set
--           p_category_structure_id  Identifier for structure of item
--                                    category
--           p_item_category_from     High range of item category
--           p_item_category_to       Low range of item category
--           p_item_name_source       Iten name source, alternative
--                                    value is 'MASTER_ITEM' or
--                                    'LATEST_ITEM_CROSS_REFERENCE',
--                                    this parameter is to decide
--                                    where item name is got from
--           p_cross_reference_type   Cross reference type of item
--           p_item_status            Item status
--           p_creation_date_from     High range of item creation date
--           p_creation_date_to       Low range of item creation date
--
--      Out:
--
--
--  DESIGN REFERENCES:
--    GTA-Txt-Interface-TD.doc
--
--  CHANGE HISTORY:
--
--           17-MAY-2005	Donghai Wang Created
--
--===========================================================================
PROCEDURE Export_Items
( p_org_id                 IN  NUMBER
, p_master_org_id          IN  NUMBER
, p_item_num_from          IN  VARCHAR2
, p_item_num_to            IN  VARCHAR2
, p_category_set_id        IN  NUMBER
, p_category_structure_id  IN  NUMBER
, p_item_category_from     IN  VARCHAR2
, p_item_category_to       IN  VARCHAR2
, p_item_name_source       IN  VARCHAR2
, p_cross_reference_type   IN  VARCHAR2
, p_item_status            IN  VARCHAR2
, p_creation_date_from     IN  VARCHAR2
, p_creation_date_to       IN  VARCHAR2
);

END AR_GTA_TXT_OPERATOR_PROC;



/
