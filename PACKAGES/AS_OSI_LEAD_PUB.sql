--------------------------------------------------------
--  DDL for Package AS_OSI_LEAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OSI_LEAD_PUB" AUTHID CURRENT_USER as
/* $Header: custom_asxposis.pls 115.3.1157.2 2002/02/21 09:11:49 pkm ship      $ */

-- Start of Comments
--
-- NAME
--   AS_OSI_LEAD_PUB
--
-- PURPOSE
--   This package is a public API for inserting OSI enhanced oppy information into
--   OSM. It contains specification for pl/sql records and tables and the
--   Public fetch and update API.
--
--   Procedures:
--      osi_lead_fetch (see below for specification)
--      osi_lead_update (see below for specification)

--
-- NOTES
--   This package is publicly available for use
--
--
--
-- HISTORY
--   12/12/99   JHIBNER                Created
-- End of Comments


--     ***********************
--          Composite Types
--     ***********************

-- Start of Comments
--
--    OSI Opportunity Header Record: osi_rec_type
--
--    Required:
-- LEAD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
-- CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
--
--      Defaults:
-- LAST_UPDATE_DATE, LAST_UPDATED_BY,
-- CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN get standard stuff
-- End of Comments

TYPE osi_rec_type        IS RECORD
    (   last_update_date       Date             := FND_API.G_MISS_DATE,
        last_updated_by        varchar2(30)           := FND_API.G_MISS_CHAR,
        creation_Date          Date             := FND_API.G_MISS_DATE,
        created_by             varchar2(30)           := FND_API.G_MISS_CHAR,
        last_update_login      varchar2(30)           := FND_API.G_MISS_CHAR,
        lead_id                NUMBER		:= FND_API.G_MISS_NUM,
        osi_lead_id                NUMBER		:= FND_API.G_MISS_NUM,
        CVEHICLE				  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CNAME_ID				  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        PO_FROM            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CONTR_TYPE            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CONTR_DRAFTING_REQ            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        PRIORITY            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        SENIOR_CONTR_person_ID    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CONTR_SPEC_person_ID    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        BOM_person_ID    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        LEGAL_person_ID    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        HIGHEST_APVL            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CURRENT_APVL_STATUS            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        SUPPORT_APVL            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        INTERNATIONAL_APVL            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CREDIT_APVL            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        FIN_ESCROW_REQ            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        FIN_ESCROW_STATUS            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CSI_ROLLIN            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        LICENCE_CREDIT_VER            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        SUPPORT_CREDIT_VER            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        MD_DEAL_SUMMARY            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        PROD_AVAIL_VER            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        SHIP_LOCATION            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        TAX_EXEMPT_CERT            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        NL_REV_ALLOC_REQ            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CONSULTING_CC            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        SENIOR_CONTR_NOTES            VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
        LEGAL_NOTES           VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
        BOM_NOTES            VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
        CONTR_NOTES            VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
        CONTR_STATUS            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        EXTRA_DOCS            VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CUST_NAME            VARCHAR2(50)	:= FND_API.G_MISS_CHAR,
        SITE_NAME            VARCHAR2(50)	:= FND_API.G_MISS_CHAR,
        OPPY_NAME            VARCHAR2(50)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_REC        osi_rec_type;

-- Start of Comments
--
--  Opportunity Table:    osi_tbl_type
--
--
-- End of Comments

TYPE osi_tbl_type        IS TABLE OF    osi_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_TBL        osi_tbl_type;

TYPE osi_cvb_rec_type        IS RECORD
    (   CVEHICLE				  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        VEHICLE    VARCHAR2(100)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_CVB_REC        osi_cvb_rec_type;

TYPE osi_cvb_tbl_type        IS TABLE OF    osi_cvb_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_CVB_TBL        osi_cvb_tbl_type;

TYPE osi_cnb_rec_type        IS RECORD
    (   CVEHICLE				  VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        CONTR_NAME    VARCHAR2(50)	:= FND_API.G_MISS_CHAR,
        CNAME_ID                                 VARCHAR2(30)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_CNB_REC        osi_cnb_rec_type;

TYPE osi_cnb_tbl_type        IS TABLE OF    osi_cnb_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_CNB_TBL        osi_cnb_tbl_type;

TYPE osi_lkp_rec_type        IS RECORD
    (   LKP_TYPE    VARCHAR2(100)	:= FND_API.G_MISS_CHAR,
        LKP_CODE    VARCHAR2(100)	:= FND_API.G_MISS_CHAR,
        LKP_VALUE    VARCHAR2(200)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_LKP_REC        osi_lkp_rec_type;

TYPE osi_lkp_tbl_type        IS TABLE OF    osi_lkp_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_LKP_TBL        osi_lkp_tbl_type;

TYPE osi_nam_rec_type        IS RECORD
    (   NAM_TYPE    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        NAM_ID    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        NAM_VALUE    VARCHAR2(30)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_NAM_REC        osi_nam_rec_type;

TYPE osi_nam_tbl_type        IS TABLE OF    osi_nam_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_NAM_TBL        osi_nam_tbl_type;

TYPE osi_ccs_rec_type        IS RECORD
    (   CC    VARCHAR2(3)	:= FND_API.G_MISS_CHAR,
        CENTER_NAME    VARCHAR2(50)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_CCS_REC        osi_ccs_rec_type;

TYPE osi_ccs_tbl_type        IS TABLE OF    osi_ccs_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_CCS_TBL        osi_ccs_tbl_type;

TYPE osi_ovm_rec_type        IS RECORD
    (   OVM_CODE    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        OVM_VALUE    VARCHAR2(30)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_OVM_REC        osi_ovm_rec_type;

TYPE osi_ovm_tbl_type        IS TABLE OF    osi_ovm_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_OVM_TBL        osi_ovm_tbl_type;

TYPE osi_ovd_rec_type        IS RECORD
    (   OVD_CODE    VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
        OVD_FLAG    VARCHAR2(30)	:= FND_API.G_MISS_CHAR
        );

G_MISS_OSI_OVD_REC        osi_ovd_rec_type;

TYPE osi_ovd_tbl_type        IS TABLE OF    osi_ovd_rec_type
                    INDEX BY BINARY_INTEGER;

G_MISS_OSI_OVD_TBL        osi_ovd_tbl_type;

PROCEDURE osi_lead_fetch
(   p_api_version_number    IN     NUMBER,
    p_lead_id				in    VARCHAR2,
    p_osi_rec                       out    OSI_REC_TYPE   ,
    p_osi_ovd_tbl                       out    OSI_OVD_TBL_TYPE
);
PROCEDURE osi_lead_fetch_all
(   p_api_version_number    IN     NUMBER,
    p_lead_id				in    VARCHAR2,
    p_osi_rec                       out    OSI_REC_TYPE     ,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE  ,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE     ,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE,
    p_osi_ovd_tbl                       out    OSI_OVD_TBL_TYPE,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
);
PROCEDURE osi_lookup_fetch_all
(   p_api_version_number    IN     NUMBER,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE  ,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE     ,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
);
PROCEDURE osi_lead_update
(   p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
    p_osi_rec               IN     OSI_REC_TYPE,
    p_osi_ovd_tbl           IN     OSI_OVD_TBL_TYPE,
    x_return_status         OUT    VARCHAR2,
    x_msg_count             OUT    VARCHAR2,
    x_msg_data              OUT    VARCHAR2
);
PROCEDURE osi_cvb_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_cvb_tbl                       out    OSI_CVB_TBL_TYPE
);
PROCEDURE osi_cnb_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_cnb_tbl                       out    OSI_CNB_TBL_TYPE
);
PROCEDURE osi_lkp_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_lkp_type          in     varchar2,
    p_osi_lkp_tbl                       out    OSI_LKP_TBL_TYPE
);
PROCEDURE osi_nam_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_nam_type          in     varchar2,
    p_osi_nam_tbl                       out    OSI_NAM_TBL_TYPE
);
PROCEDURE osi_ccs_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_ccs_tbl                       out    OSI_CCS_TBL_TYPE
);
PROCEDURE osi_ovm_fetch
(   p_api_version_number    IN     NUMBER,
    p_osi_ovm_tbl                       out    OSI_OVM_TBL_TYPE
);
FUNCTION osi_get_button_html
(   p_api_version_number    IN     NUMBER
) return varchar2;
FUNCTION osi_get_js_html
(   p_api_version_number    IN     NUMBER
) return varchar2;
end AS_OSI_LEAD_PUB;

 

/
