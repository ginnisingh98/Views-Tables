--------------------------------------------------------
--  DDL for Package ASO_SUP_TMPL_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUP_TMPL_INSTANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: asosptis.pls 120.1 2005/06/29 12:38:25 appldev ship $*/

-- Purpose: To Insert/Update/delete/Lock data for ASO_SUP_TMPL_INSTANCE table for HTML Quoting
-- File name asosptis.pls


-- MODIFICATION HISTORY
-- Person            Date          Comments
-- ---------         ------        ------------------------------------------
-- Sarala Biswal    01/18/02      Created Package

--------------------------------------------------------------------------------------
                      -- API Signatures --
--------------------------------------------------------------------------------------
	-- 1.
    	-- Start of comments
	--   API name        : INSERT_ROW
    --   Purpose         : Procedure to insert into ASO_SUP_TMPL_INSTANCE table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              : P_SECTION_ID             IN    NUMBER            Required
        --                 P_TEMPLATE_ID            IN    NUMBER            Required
        --                 P_TEMPLATE_ID        IN NUMBER,
        --                 P_Owner_Table_Name   IN VARCHAR2,
        --                 P_Owner_Table_Id      IN NUMBER,



	--   IN OUT NOCOPY /* file.sql.39 change */          : PX_TEMPLATE_SECTION_MAP_ID            IN OUT NUMBER
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------


PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_TEMPLATE_INSTANCE_ID       IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_ID        IN NUMBER,
  P_Owner_Table_Name   IN VARCHAR2,
  P_Owner_Table_Id      IN NUMBER,
  P_CONTEXT             IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9          IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE16         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE17         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE18         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE19         IN VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE20         IN VARCHAR2 DEFAULT NULL,
  p_OBJECT_VERSION_NUMBER  IN NUMBER
);


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 2.
    	-- Start of comments
	--   API name        : UPDATE_ROW
    --   Purpose         : Procedure to update ASO_SUP_TMPL_INSTANCE table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --                 P_TEMPLATE_INSTANCE_ID      IN    NUMBER            Required
        --                 P_TEMPLATE_ID               IN    NUMBER            Required
        --                 P_DISPLAY_SEQUENCE          IN    NUMBER            Required



	--   OUT NOCOPY /* file.sql.39 change */              : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------



PROCEDURE UPDATE_ROW
(
  P_TEMPLATE_INSTANCE_ID       IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_ID          IN NUMBER,
  P_Owner_Table_Name    IN VARCHAR2,
  P_Owner_Table_Id      IN NUMBER,
  P_CONTEXT             IN VARCHAR2,
  P_ATTRIBUTE1          IN VARCHAR2,
  P_ATTRIBUTE2          IN VARCHAR2,
  P_ATTRIBUTE3          IN VARCHAR2,
  P_ATTRIBUTE4          IN VARCHAR2,
  P_ATTRIBUTE5          IN VARCHAR2,
  P_ATTRIBUTE6          IN VARCHAR2,
  P_ATTRIBUTE7          IN VARCHAR2,
  P_ATTRIBUTE8          IN VARCHAR2,
  P_ATTRIBUTE9          IN VARCHAR2,
  P_ATTRIBUTE10         IN VARCHAR2,
  P_ATTRIBUTE11         IN VARCHAR2,
  P_ATTRIBUTE12         IN VARCHAR2,
  P_ATTRIBUTE13         IN VARCHAR2,
  P_ATTRIBUTE14         IN VARCHAR2,
  P_ATTRIBUTE15         IN VARCHAR2,
  P_ATTRIBUTE16         IN VARCHAR2,
  P_ATTRIBUTE17         IN VARCHAR2,
  P_ATTRIBUTE18         IN VARCHAR2,
  P_ATTRIBUTE19         IN VARCHAR2,
  P_ATTRIBUTE20         IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER  IN NUMBER
);



--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 3.
    	-- Start of comments
	--   API name        : DELETE_ROW
    --   Purpose         : Procedure to delete from ASO_SUP_TMPL_INSTANCE table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --  		       P_TEMPLATE_INSTANCE_ID       IN    NUMBER              Required

	--   OUT NOCOPY /* file.sql.39 change */             : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------

procedure DELETE_ROW (
  P_TEMPLATE_INSTANCE_ID IN NUMBER

);


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 4.
    	-- Start of comments
	--   API name        : LOCK_ROW
    --   Purpose         : Procedure to Lock ASO_SUP_TMPL_INSTANCE table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --                 P_TEMPLATE_INSTANCE_ID      IN    NUMBER            Required
        --                 P_TEMPLATE_ID               IN    NUMBER            Required
        --                 P_SECTION_ID                IN    NUMBER            Required
        --                 P_DISPLAY_SEQUENCE          IN    NUMBER            Required

        --


	--   OUT NOCOPY /* file.sql.39 change */             :

	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------
PROCEDURE LOCK_ROW
(
  P_TEMPLATE_INSTANCE_ID       IN NUMBER,
  --p_OBJECT_VERSION_NUMBER  IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_ID         IN NUMBER,
  P_Owner_Table_Name   IN VARCHAR2,
  P_Owner_Table_Id      IN NUMBER,
  P_CONTEXT             IN VARCHAR2,
  P_ATTRIBUTE1          IN VARCHAR2,
  P_ATTRIBUTE2          IN VARCHAR2,
  P_ATTRIBUTE3          IN VARCHAR2,
  P_ATTRIBUTE4          IN VARCHAR2,
  P_ATTRIBUTE5          IN VARCHAR2,
  P_ATTRIBUTE6          IN VARCHAR2,
  P_ATTRIBUTE7          IN VARCHAR2,
  P_ATTRIBUTE8          IN VARCHAR2,
  P_ATTRIBUTE9          IN VARCHAR2,
  P_ATTRIBUTE10         IN VARCHAR2,
  P_ATTRIBUTE11         IN VARCHAR2,
  P_ATTRIBUTE12         IN VARCHAR2,
  P_ATTRIBUTE13         IN VARCHAR2,
  P_ATTRIBUTE14         IN VARCHAR2,
  P_ATTRIBUTE15         IN VARCHAR2
);



END; -- Package Specification ASO_SUP_TMPL_INSTANCE_PKG

 

/
