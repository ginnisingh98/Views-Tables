--------------------------------------------------------
--  DDL for Package AMS_ATCH_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ATCH_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: amsvatus.pls 115.4 2002/12/05 01:04:22 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ATCH_UPGRADE
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ATCH_UPGRADE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvatub.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_LOB_From_BFILE(
                                 p_file_name IN Varchar2,
				 p_dir_name  IN Varchar2,
				 x_file_id   OUT NOCOPY  Number
                              );
END AMS_ATCH_UPGRADE;

 

/
