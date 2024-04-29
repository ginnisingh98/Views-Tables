--------------------------------------------------------
--  DDL for Package AHL_VWP_VISIT_MR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISIT_MR_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVVMRS.pls 120.0 2005/05/26 11:00:21 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_Visit_MR_Pvt
--
-- PURPOSE
--    This package is a Private API for managing Visit Stages information in CMRO.
--    It contains specification for pl/sql records and tables
--
--    Process_Visit_MRs (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 06-MAY-2003    SHBHANDA      Created.
-----------------------------------------------------------

-------------------------------------
-- Visit MR Record Type   -----
-------------------------------------
--
TYPE Visit_MR_Rec_Type IS RECORD (
   VISIT_TASK_ID              NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   ATTRIBUTE_CATEGORY         VARCHAR2(30),
   ATTRIBUTE1                 VARCHAR2(150),
   ATTRIBUTE2                 VARCHAR2(150),
   ATTRIBUTE3                 VARCHAR2(150),
   ATTRIBUTE4                 VARCHAR2(150),
   ATTRIBUTE5                 VARCHAR2(150),
   ATTRIBUTE6                 VARCHAR2(150),
   ATTRIBUTE7                 VARCHAR2(150),
   ATTRIBUTE8                 VARCHAR2(150),
   ATTRIBUTE9                 VARCHAR2(150),
   ATTRIBUTE10                VARCHAR2(150),
   ATTRIBUTE11                VARCHAR2(150),
   ATTRIBUTE12                VARCHAR2(150),
   ATTRIBUTE13                VARCHAR2(150),
   ATTRIBUTE14                VARCHAR2(150),
   ATTRIBUTE15                VARCHAR2(150),
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   lAST_UPDATE_LOGIN          NUMBER,
   OPERATION_FLAG             VARCHAR2(1)
  );

  --  Table type for storing Visit_MR_Rec_Type
TYPE Visit_MR_Tbl_Type IS TABLE OF Visit_MR_Rec_Type
   INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Visit_MRs
--
-- PURPOSE
--    Process Visit MRs entry.
--
-- PARAMETERS
--
--
--
-- NOTES
--    1. Procedure helps out to link between JSP page and API package
--    2. On the basis  of operation flag as one field in each record type
--       the further procedure for create/update/delete for Visit MRs.
---------------------------------------------------------------------

PROCEDURE Process_Visit_MRs (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type          IN  VARCHAR2  := 'JSP',
   p_Visit_MR_Tbl         IN  Visit_MR_Tbl_Type,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

END AHL_VWP_VISIT_MR_PVT;

 

/
