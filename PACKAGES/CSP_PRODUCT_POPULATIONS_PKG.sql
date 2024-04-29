--------------------------------------------------------
--  DDL for Package CSP_PRODUCT_POPULATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PRODUCT_POPULATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: csptprps.pls 115.3 2002/11/26 07:27:50 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_PRODUCT_POPULATIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PRODUCT_POPULATION_ID   IN OUT NOCOPY NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_CURRENT_POPULATION    NUMBER
         ,p_POPULATION_CHANGE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
);
PROCEDURE Update_Row(
          p_PRODUCT_POPULATION_ID    NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_CURRENT_POPULATION    NUMBER
         ,p_POPULATION_CHANGE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
);
PROCEDURE Lock_Row(
          p_PRODUCT_POPULATION_ID    NUMBER
         ,p_PLANNING_PARAMETERS_ID    NUMBER
         ,p_PRODUCT_ID    NUMBER
         ,p_CURRENT_POPULATION    NUMBER
         ,p_POPULATION_CHANGE    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
);
PROCEDURE Delete_Row(
    p_PRODUCT_POPULATION_ID  NUMBER);
End CSP_PRODUCT_POPULATIONS_PKG;

 

/
