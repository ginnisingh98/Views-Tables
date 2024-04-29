--------------------------------------------------------
--  DDL for Package CSE_GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_GL_INTERFACE_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEGLINS.pls 120.7 2006/03/15 14:47 kuchauha noship $


TYPE gl_interface_rec is RECORD (

STATUS                           VARCHAR2(50) ,
LEDGER_ID                        NUMBER(15,0) ,
ACCOUNTING_DATE                  DATE	      ,
CURRENCY_CODE                    VARCHAR2(15) ,
DATE_CREATED                     DATE	      ,
CREATED_BY                       NUMBER(15,0) ,
ACTUAL_FLAG                      VARCHAR2(1)  ,
USER_JE_CATEGORY_NAME            VARCHAR2(25) ,
USER_JE_SOURCE_NAME              VARCHAR2(25) ,
CURRENCY_CONVERSION_DATE         DATE	      ,
ENCUMBRANCE_TYPE_ID              NUMBER	      ,
BUDGET_VERSION_ID                NUMBER	      ,
USER_CURRENCY_CONVERSION_TYPE    VARCHAR2(30) ,
CURRENCY_CONVERSION_RATE         NUMBER	      ,
SEGMENT1                         VARCHAR2(25) ,
SEGMENT2                         VARCHAR2(25) ,
SEGMENT3                         VARCHAR2(25) ,
SEGMENT4                         VARCHAR2(25) ,
SEGMENT5                         VARCHAR2(25) ,
SEGMENT6                         VARCHAR2(25) ,
SEGMENT7                         VARCHAR2(25) ,
SEGMENT8                         VARCHAR2(25) ,
SEGMENT9                         VARCHAR2(25) ,
SEGMENT10                        VARCHAR2(25) ,
SEGMENT11                        VARCHAR2(25) ,
SEGMENT12                        VARCHAR2(25) ,
SEGMENT13                        VARCHAR2(25) ,
SEGMENT14                        VARCHAR2(25) ,
SEGMENT15                        VARCHAR2(25) ,
SEGMENT16                        VARCHAR2(25) ,
SEGMENT17                        VARCHAR2(25) ,
SEGMENT18                        VARCHAR2(25) ,
SEGMENT19                        VARCHAR2(25) ,
SEGMENT20                        VARCHAR2(25) ,
SEGMENT21                        VARCHAR2(25) ,
SEGMENT22                        VARCHAR2(25)   ,
SEGMENT23                        VARCHAR2(25)  ,
SEGMENT24                        VARCHAR2(25)  ,
SEGMENT25                        VARCHAR2(25)  ,
SEGMENT26                        VARCHAR2(25)  ,
SEGMENT27                        VARCHAR2(25)  ,
SEGMENT28                        VARCHAR2(25)  ,
SEGMENT29                        VARCHAR2(25)  ,
SEGMENT30                        VARCHAR2(25)  ,
ENTERED_DR                       NUMBER	       ,
ENTERED_CR                       NUMBER	       ,
ACCOUNTED_DR                     NUMBER	       ,
ACCOUNTED_CR                     NUMBER	       ,
TRANSACTION_DATE                 DATE	       ,
REFERENCE1                       VARCHAR2(100)  ,
REFERENCE2                       VARCHAR2(240)	,
REFERENCE3                       VARCHAR2(100)  ,
REFERENCE4                       VARCHAR2(100)  ,
REFERENCE5                       VARCHAR2(240)  ,
REFERENCE6                       VARCHAR2(100)  ,
REFERENCE7                       VARCHAR2(100)  ,
REFERENCE8                       VARCHAR2(100)  ,
REFERENCE9                       VARCHAR2(100)  ,
REFERENCE10                      VARCHAR2(240)  ,
REFERENCE11                      VARCHAR2(240)  ,
REFERENCE12                      VARCHAR2(100)  ,
REFERENCE13                      VARCHAR2(100)  ,
REFERENCE14                      VARCHAR2(100)  ,
REFERENCE15                      VARCHAR2(100)  ,
REFERENCE16                      VARCHAR2(100)  ,
REFERENCE17                      VARCHAR2(100) ,
REFERENCE18                      VARCHAR2(100) ,
REFERENCE19                      VARCHAR2(100) ,
REFERENCE20                      VARCHAR2(100) ,
REFERENCE21                      VARCHAR2(240) ,
REFERENCE22                      VARCHAR2(240) ,
REFERENCE23                      VARCHAR2(240) ,
REFERENCE24                      VARCHAR2(240) ,
REFERENCE25                      VARCHAR2(240) ,
REFERENCE26                      VARCHAR2(240) ,
REFERENCE27                      VARCHAR2(240) ,
REFERENCE28                      VARCHAR2(240) ,
REFERENCE29                      VARCHAR2(240) ,
REFERENCE30                      VARCHAR2(240) ,
JE_BATCH_ID                      NUMBER(15,0) ,
PERIOD_NAME                      VARCHAR2(15)	,
JE_HEADER_ID                     NUMBER(15,0) ,
JE_LINE_NUM                      NUMBER(15,0) ,
CHART_OF_ACCOUNTS_ID             NUMBER(15,0) ,
FUNCTIONAL_CURRENCY_CODE         VARCHAR2(15)	,
CODE_COMBINATION_ID              NUMBER(15,0) ,
DATE_CREATED_IN_GL               DATE	      ,
WARNING_CODE                     VARCHAR2(4)	,
STATUS_DESCRIPTION               VARCHAR2(240),
STAT_AMOUNT                      NUMBER	      ,
GROUP_ID                         NUMBER(15,0) ,
REQUEST_ID                       NUMBER(15,0) ,
SUBLEDGER_DOC_SEQUENCE_ID        NUMBER	      ,
SUBLEDGER_DOC_SEQUENCE_VALUE     NUMBER	      ,
ATTRIBUTE1                       VARCHAR2(150),
ATTRIBUTE2                       VARCHAR2(150),
ATTRIBUTE3                       VARCHAR2(150),
ATTRIBUTE4                       VARCHAR2(150),
ATTRIBUTE5                       VARCHAR2(150),
ATTRIBUTE6                       VARCHAR2(150),
ATTRIBUTE7                       VARCHAR2(150),
ATTRIBUTE8                       VARCHAR2(150),
ATTRIBUTE9                       VARCHAR2(150),
ATTRIBUTE10                      VARCHAR2(150),
ATTRIBUTE11                      VARCHAR2(150),
ATTRIBUTE12                      VARCHAR2(150),
ATTRIBUTE13                      VARCHAR2(150),
ATTRIBUTE14                      VARCHAR2(150),
ATTRIBUTE15                      VARCHAR2(150),
ATTRIBUTE16                      VARCHAR2(150),
ATTRIBUTE17                      VARCHAR2(150),
ATTRIBUTE18                      VARCHAR2(150),
ATTRIBUTE19                      VARCHAR2(150),
ATTRIBUTE20                      VARCHAR2(150),
CONTEXT                          VARCHAR2(150),
CONTEXT2                         VARCHAR2(150),
INVOICE_DATE                     DATE	      ,
TAX_CODE                         VARCHAR2(15) ,
INVOICE_IDENTIFIER               VARCHAR2(20) ,
INVOICE_AMOUNT                   NUMBER	      ,
CONTEXT3                         VARCHAR2(150),
USSGL_TRANSACTION_CODE           VARCHAR2(30) ,
DESCR_FLEX_ERROR_MESSAGE         VARCHAR2(240),
JGZZ_RECON_REF                   VARCHAR2(240),
AVERAGE_JOURNAL_FLAG             VARCHAR2(1)  ,
ORIGINATING_BAL_SEG_VALUE        VARCHAR2(25) ,
GL_SL_LINK_ID                    NUMBER	      ,
GL_SL_LINK_TABLE                 VARCHAR2(30) ,
REFERENCE_DATE                   DATE	      ,
SET_OF_BOOKS_ID                  NUMBER(15,0) ,
BALANCING_SEGMENT_VALUE          VARCHAR2(25) ,
MANAGEMENT_SEGMENT_VALUE         VARCHAR2(25) ,
CODE_COMBINATION_ID_INTERIM      NUMBER(15)    ) ;

  TYPE gl_interface_tbl is TABLE OF gl_interface_rec INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------------

PROCEDURE get_gl_interface_code(
             p_mtl_txn_id        IN NUMBER
            ,p_csi_txn_id        IN NUMBER
            ,x_gl_interface_code OUT NOCOPY NUMBER
            ,x_return_status     OUT NOCOPY VARCHAR2
            ,x_error_message     OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------------

PROCEDURE Create_gl_entries
 (x_return_status           OUT NOCOPY VARCHAR2,
  x_error_msg               OUT NOCOPY VARCHAR2,
  p_conc_request_id         IN NUMBER );


-------------------------------------------------------------------------------------
END CSE_GL_INTERFACE_PKG; -- Package spec

 

/