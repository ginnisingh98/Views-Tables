--------------------------------------------------------
--  DDL for Package GMD_FORMULA_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_DETAIL_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVFMDS.pls 120.0.12010000.1 2008/07/24 10:01:39 appldev ship $ */

-- Start of commments
-- API name     : Insert_FormulaDetail
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--                      p_commit     IN Varchar2  Optional
--                      p_formula_detail_rec_type  Required
--
-- OUT                  x_return_status    OUT varchar2(1)
--                      x_msg_count        OUT Number
--                      x_msg_data         OUT varchar2(2000)
--
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

PROCEDURE Insert_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_rec    IN      fm_matl_dtl%ROWTYPE
);


-- Start of commments
-- API name     : Update_FormulaDetail
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--                      p_commit     IN Varchar2  Optional
--                      p_formula_detail_rec_type IN formula_header_rec_type Required
--
-- OUT                  x_return_status    OUT varchar2(1)
--                      x_msg_count        OUT Number
--                      x_msg_data         OUT varchar2(2000)
--
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

PROCEDURE Update_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_rec    IN      fm_matl_dtl%ROWTYPE
);


-- Start of commments
-- API name     : Delete_FormulaDetail
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--                      p_commit     IN Varchar2  Optional
--                      p_formula_detail_rec_type IN formula_header_rec_type Required
--
-- OUT                  x_return_status    OUT varchar2(1)
--                      x_msg_count        OUT Number
--                      x_msg_data         OUT varchar2(2000)
--
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

PROCEDURE Delete_FormulaDetail
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_detail_rec    IN      fm_matl_dtl%ROWTYPE
);


END GMD_FORMULA_DETAIL_PVT;

/
