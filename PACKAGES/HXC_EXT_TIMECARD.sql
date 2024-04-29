--------------------------------------------------------
--  DDL for Package HXC_EXT_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_EXT_TIMECARD" AUTHID CURRENT_USER as
/* $Header: hxcxtime.pkh 120.0 2005/05/29 05:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Public Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= ' hxc_ext_timecard.';  -- Global package name

-- Summary Level Timecard Data Elements

OTL_TC_START_DATE              DATE;
OTL_TC_END_DATE                DATE;
OTL_TC_STATUS                  VARCHAR2(30);
OTL_TC_COMMENTS                VARCHAR2(2000);
OTL_TC_DELTED                  VARCHAR2(1);

-- Detail Level Timecard Data Elements

OTL_DAY                        DATE;
OTL_DAY_COMMENTS               VARCHAR2(2000);
OTL_MEASURE                    NUMBER;
OTL_DAY_START                  DATE;
OTL_DAY_STOP                   DATE;
OTL_PA_SYS_LINK_FUNCN          VARCHAR2(3);
OTL_PA_BILLABLE_FLAG           VARCHAR2(1);
OTL_PA_TASK                    VARCHAR2(25);
OTL_PA_PROJECT                 VARCHAR2(25);
OTL_PA_EXPENDITURE_TYPE        VARCHAR2(30);
OTL_PA_EXPENDITURE_COMMENT     VARCHAR2(150);
OTL_PAY_ELEMENT_NAME           VARCHAR2(80);
OTL_PAY_COST_CENTRE            VARCHAR2(80);
OTL_PO_NUMBER                  VARCHAR2(20);
OTL_PO_LINE_ID                 NUMBER(15);
OTL_PO_PRICE_TYPE              VARCHAR2(30);
OTL_ALIAS_ELEMENTS_EXP_SLF     VARCHAR2(80);
OTL_ALIAS_EXPENDITURE_ELEMENTS VARCHAR2(80);
OTL_ALIAS_EXPENDITURE_TYPES    VARCHAR2(80);
OTL_ALIAS_LOCATIONS            VARCHAR2(80);
OTL_ALIAS_PAYROLL_ELEMENTS     VARCHAR2(80);
OTL_ALIAS_PROJECTS             VARCHAR2(80);
OTL_ALIAS_TASKS                VARCHAR2(80);
OTL_ALIAS_RATE_TYPE_EXP_SLF    VARCHAR2(80);

-- Global parameter record for PO

TYPE param_rec IS RECORD (
  start_date          DATE
, end_date            DATE
, status              VARCHAR2(30)
, vendor_id           NUMBER(15)
, retrieval_process   VARCHAR2(80)
, buyer_supplier      VARCHAR2(30)
, p_business_group_id NUMBER(15)
, p_person_id         NUMBER(15) );

g_params param_rec;

PROCEDURE po_otl_extract (
                errbuf               out NOCOPY varchar2,
                retcode              out NOCOPY number,
                p_ext_dfn_id	     in number,
                p_effective_date     in varchar2,
                p_business_group_id  in number,
                p_start_date        in varchar2,
                p_end_date          in varchar2,
                p_timecard_status   in varchar2,
                p_vendor_id         in varchar2 default null,
                p_person_id         in varchar2 default null,
                p_retrieval_process in varchar2,
                p_buyer_supplier    in varchar2 default 'BUYER' );

PROCEDURE process_summary (
  p_person_id          in number,
  p_ext_rslt_id        in number,
  p_ext_file_id        in number,
  p_ext_crit_prfl_id   in number,
  p_data_typ_cd        in varchar2,
  p_ext_typ_cd         in varchar2,
  p_effective_date     in date );

PROCEDURE process_detail (
   p_tbb_id             in number,
   p_tbb_ovn            in number,
   p_person_id          in number,
   p_ext_rslt_id        in number,
   p_ext_file_id        in number,
   p_ext_crit_prfl_id   in number,
   p_data_typ_cd        in varchar2,
   p_ext_typ_cd         in varchar2,
   p_effective_date     in date );

end hxc_ext_timecard;

 

/
