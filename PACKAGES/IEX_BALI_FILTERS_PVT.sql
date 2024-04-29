--------------------------------------------------------
--  DDL for Package IEX_BALI_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_BALI_FILTERS_PVT" AUTHID CURRENT_USER as
/* $Header: iexvbfls.pls 120.3 2004/06/04 19:58:58 jsanju noship $ */
-- Start of Comments
-- Package name     : IEX_BALI_FILTERS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME              CONSTANT VARCHAR2(200) := 'IEX_BALI_FILTERS_PVT';
 G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_DEFAULT_NUM_REC_FETCH CONSTANT NUMBER := 30;
 G_YES                   CONSTANT VARCHAR2(1) := 'Y';
 G_NO                    CONSTANT VARCHAR2(1) := 'N';
------------------------------------------------------------------------------


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE bali_filter_rec_type IS RECORD
(
	 bali_filter_id	           number
    ,bali_filter_name           varchar2(100)
    ,bali_datasource            varchar2(100)
    ,bali_user_id               number
    ,bali_col_alias             varchar2(30)
    ,bali_col_data_type         varchar2(30)
    ,bali_col_label_text        varchar2(80)
    ,bali_col_condition_code    varchar2(30)
    ,bali_col_condition_value   varchar2(30)
    ,bali_col_value             varchar2(100)
    ,right_parenthesis_code     varchar2(100)
    ,left_parenthesis_code      varchar2(100)
    ,boolean_operator_code      varchar2(100)
	,object_version_number      number
     ,request_id                number ,
     program_application_id     number ,
     program_id                 number ,
     program_update_date        date ,
     attribute_category         varchar2(240) ,
     attribute1                 varchar2(240) ,
     attribute2                 varchar2(240) ,
     attribute3                 varchar2(240) ,
     attribute4                 varchar2(240) ,
     attribute5                 varchar2(240) ,
     attribute6                 varchar2(240) ,
     attribute7                 varchar2(240) ,
     attribute8                 varchar2(240) ,
     attribute9                 varchar2(240) ,
     attribute10                varchar2(240) ,
     attribute11                varchar2(240) ,
     attribute12                varchar2(240) ,
     attribute13                varchar2(240) ,
     attribute14                varchar2(240) ,
     attribute15                varchar2(240) ,
     created_by                 number ,
     creation_date              date ,
     last_updated_by            number ,
     last_update_date           date ,
     last_update_login          number
);

G_MISS_bali_filter_rec          bali_filter_rec_type;
TYPE  bali_filter_tbl_Type      IS TABLE OF bali_filter_rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_bali_filter_tbl          bali_filter_tbl_Type;



PROCEDURE create_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_bali_filter_rec            IN   bali_filter_rec_type,
    X_bali_filter_id             OUT  NOCOPY NUMBER
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
    );

PROCEDURE update_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_bali_filter_rec            IN    bali_filter_rec_type,
    x_return_status             OUT  NOCOPY VARCHAR2
    ,x_msg_count                OUT  NOCOPY NUMBER
    ,x_msg_data                 OUT  NOCOPY VARCHAR2
    ,XO_OBJECT_VERSION_NUMBER   OUT  NOCOPY NUMBER
    );

PROCEDURE  delete_BALI_FILTERS(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_bali_filter_id             IN   NUMBER ,
    x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2

    );

Procedure commit_work;
End IEX_BALI_FILTERS_PVT;

 

/
