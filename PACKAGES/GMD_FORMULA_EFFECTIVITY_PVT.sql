--------------------------------------------------------
--  DDL for Package GMD_FORMULA_EFFECTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_EFFECTIVITY_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVFMES.pls 120.0 2005/05/25 19:36:16 appldev noship $ */

/*
     Start of commments
     API name     : Insert_FormulaEffectivity
     Type         : Private
     Function     :
     Paramaters   :
     IN           :       p_api_version IN NUMBER   Required
                          p_init_msg_list IN Varchar2 Optional
                          p_commit     IN Varchar2  Optional
                          p_formula_effectivity_rec_type

     OUT                  x_return_status    OUT varchar2(1)
                          x_msg_count        OUT Number
                          x_msg_data         OUT varchar2(2000)

     Version :  Current Version 1.0

     Notes  :
     End of comments
*/

PROCEDURE Insert_FormulaEffectivity
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_effectivity_rec    IN      fm_form_eff%ROWTYPE
);

/*
     Start of commments
     API name     : Update_FormulaEffectivity
     Type         : Private
     Function     :
     Paramaters   :
     IN           :       p_api_version IN NUMBER   Required
                          p_init_msg_list IN Varchar2 Optional
                          p_commit     IN Varchar2  Optional
                          p_formula_effectivity_rec_type IN
                          p_delete_mark  IN NUMBER  Required

     OUT                  x_return_status    OUT varchar2(1)
                          x_msg_count        OUT Number
                          x_msg_data         OUT varchar2(2000)

     Version :  Current Version 1.0

     Notes  :

     End of comments
*/

PROCEDURE Update_FormulaEffectivity
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        p_formula_effectivity_rec    IN      fm_form_eff%ROWTYPE
);


END GMD_FORMULA_EFFECTIVITY_PVT;

 

/
