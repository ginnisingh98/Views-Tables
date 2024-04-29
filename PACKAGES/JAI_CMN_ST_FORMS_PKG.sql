--------------------------------------------------------
--  DDL for Package JAI_CMN_ST_FORMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_ST_FORMS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_st_forms.pls 120.2 2006/07/06 08:04:59 aiyer ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Slno          Date         Bug         Remarks
---------    ---------    ----------  -------------------------------------------------------------
1.           08-Jun-2005  Version 116.1 jai_cmn_st_forms -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                  as required for CASE COMPLAINCE.
2.           05-Jul-2006  Aiyer for the bug 5369250, Version  120.2
             Issue:-
               The concurrent failes with the following error :-
               "FDPSTP failed due to ORA-01861: literal does not match format string ORA-06512: at line 1 "

             Reason:-
               The procedure generate_forms has two parameters p_from_date and p_to_date which are of type date , however the concurrent program
               passes it in the canonical format and hence the failure.

             Fix:-
              Modified the procedure generate_forms.
              Changed the datatype of p_from_date and p_to_date from date to varchar2 as this parameter.

             Dependency due to this fix:-
              None

*/

gd_from_date CONSTANT DATE DEFAULT SYSDATE ;  --rpokkula for File.Sql.35
gd_to_date  CONSTANT DATE DEFAULT SYSDATE ;   --rpokkula for File.Sql.35
gv_reprocess CONSTANT DATE DEFAULT SYSDATE ;   --rpokkula for File.Sql.35

PROCEDURE generate_ap_forms
(
p_err_buf OUT NOCOPY varchar2,
P_ret_code OUT NOCOPY varchar2,
p_org_id                                        IN              number,
p_vendor_id                             IN              number,
p_vendor_site_id                        IN              number,
p_invoice_from_date                     IN              date,
p_invoice_to_date                       IN              date,
P_reprocess                                     IN      varchar2
);

PROCEDURE generate_forms
(
errbuf OUT NOCOPY varchar2                ,
ret_code OUT NOCOPY varchar2                ,
p_from_date           varchar2,                    --default SYSDATE ,  -- Added global variable gd_from_date in package spec. by rpokkula for File.Sql.35
p_to_date             varchar2,                    --default SYSDATE ,  -- Added global variable gd_to_date in package spec. by rpokkula for File.Sql.35
p_all_orgs            varchar2                ,
p_org_id              number                  ,
p_party_type          varchar2                ,
p_party_id            number  default null    ,
p_party_site_id       number  default null    ,
p_reprocess           varchar2,                -- default 'N'    , -- Added global variable gv_reprocess in package spec. by rpokkula for File.Sql.35
P_Enable_Trace        varchar2
);


PROCEDURE generate_iso_forms(
errbuf OUT NOCOPY varchar2                ,
ret_code OUT NOCOPY varchar2                ,
p_org_id              number                  ,
p_party_type          varchar2                ,
p_party_id            number  default null    ,
p_party_site_id       number  default null    ,
p_from_date           date,                    --    default SYSDATE , -- Added global variable gd_from_date in package spec. by rpokkula for File.Sql.35
p_to_date             date                     --    default SYSDATE   -- Added global variable gd_to_date in package spec. by rpokkula for File.Sql.35
);


procedure generate_ar_forms(
errbuf OUT NOCOPY varchar2                ,
ret_code OUT NOCOPY varchar2                ,
p_org_id              number                  ,
p_party_type          varchar2                ,
p_party_id            number  default null    ,
p_party_site_id       number  default null    ,
p_from_date           date,                    --    default SYSDATE , -- Added global variable gd_from_date in package spec. by rpokkula for File.Sql.35
p_to_date             date                     --    default SYSDATE   -- Added global variable gd_to_date in package spec. by rpokkula for File.Sql.35
);



END jai_cmn_st_forms_pkg ;
 

/
