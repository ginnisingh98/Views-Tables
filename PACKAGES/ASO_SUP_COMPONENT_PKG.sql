--------------------------------------------------------
--  DDL for Package ASO_SUP_COMPONENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUP_COMPONENT_PKG" AUTHID CURRENT_USER AS
/* $Header: asospcos.pls 120.2 2005/09/20 15:46:00 skulkarn ship $*/

-- Purpose: To Insert/Update/delete data for ASO_SUP_COMPONENT_B and ASO_SUP_COMPONENT_TL table for HTML Quoting
-- File name asospcos.pls


-- MODIFICATION HISTORY
-- Person            Date          Comments
-- ---------         ------        ------------------------------------------
--  Sarala Biswal    01/17/02      Created Package

--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 1.
    	-- Start of comments
	--   API name        : INSERT_ROW
    --   Purpose         : Procedure to insert into ASO_SUP_COMPONENT_B and  ASO_SUP_COMPONENT_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              : P_COMPONENT_TYPE         IN    VARCHAR2            Required
        --                 P_MANDATORY_FLAG         IN    VARCHAR2            Required DEFAULT 'N'
        --                 P_COMPONENT_NAME         IN    VARCHAR2            Required
        --  		       P_RESPONSE_TYPE          IN    VARCHAR2            Optional


	--   IN OUT NOCOPY /* file.sql.39 change */          : COMPONENT_ID             IN OUT NUMBER
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------


PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_COMPONENT_ID       IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 DEFAULT 'N',
  P_RESPONSE_TYPE       IN VARCHAR2 DEFAULT 'TEXT',
  P_DESCRIPTION         IN VARCHAR2 DEFAULT NULL,
  P_INSTRUCTION         IN VARCHAR2 DEFAULT NULL,
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
   p_ATTRIBUTE16    VARCHAR2   DEFAULT NULL,
          p_ATTRIBUTE17    VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE18    VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE19    VARCHAR2 DEFAULT NULL,
          p_ATTRIBUTE20    VARCHAR2 DEFAULT NULL

);


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 2.
    	-- Start of comments
	--   API name        : UPDATE_ROW
    --   Purpose         : Procedure to update ASO_SUP_COMPONENT_B and  ASO_SUP_COMPONENT_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --  		       P_COPONENT_ID            IN    NUMBER              Required
        --                 P_MANDATORY_FLAG         IN    VARCHAR2            Required DEFAULT 'N'
        --                 P_COMPONENT_NAME         IN    VARCHAR2            Required
	--   OUT NOCOPY /* file.sql.39 change */             : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------



PROCEDURE UPDATE_ROW
(
  P_COMPONENT_ID        IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 ,
  P_RESPONSE_TYPE       IN VARCHAR2 ,
  P_DESCRIPTION         IN VARCHAR2 ,
  P_INSTRUCTION         IN VARCHAR2 ,
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
  p_ATTRIBUTE16    VARCHAR2,
  p_ATTRIBUTE17    VARCHAR2,
  p_ATTRIBUTE18    VARCHAR2,
  p_ATTRIBUTE19    VARCHAR2,
  p_ATTRIBUTE20    VARCHAR2
);



--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 3.
    	-- Start of comments
	--   API name        : DELETE_ROW
    --   Purpose         : Procedure to delete from ASO_SUP_COMPONENT_B and  ASO_SUP_COMPONENT_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --  		       P_COMPONENT_ID       IN    NUMBER              Required

	--   OUT NOCOPY /* file.sql.39 change */             : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------

procedure DELETE_ROW (
  P_COMPONENT_ID IN NUMBER

);


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 4.
    	-- Start of comments
	--   API name        : LOCK_ROW
    --   Purpose         : Procedure to get publish history details.
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              : P_COMPONENT_ID           IN    NUMBER              Required
        --                 P_COMPONENT_TYPE         IN    VARCHAR2            Required
        --                 P_MANDATORY_FLAG         IN    VARCHAR2            Required DEFAULT 'N'
        --                 P_COMPONENT_NAME         IN    VARCHAR2            Required
        --  		       P_RESPONSE_TYPE          IN    VARCHAR2            Optional
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
  P_COMPONENT_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 ,
  P_RESPONSE_TYPE       IN VARCHAR2 ,
  P_DESCRIPTION         IN VARCHAR2 ,
  P_INSTRUCTION         IN VARCHAR2 ,
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


procedure ADD_LANGUAGE;


procedure TRANSLATE_ROW (
   P_COMPONENT_ID IN NUMBER,
   P_COMPONENT_NAME IN VARCHAR2,
   P_DESCRIPTION in VARCHAR2,
   P_INSTRUCTION IN VARCHAR2,
   X_OWNER in VARCHAR2) ;

procedure LOAD_ROW (
  P_COMPONENT_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_COMPONENT_TYPE      IN VARCHAR2,
  P_COMPONENT_NAME      IN VARCHAR2,
  P_MANDATORY_FLAG      IN VARCHAR2 DEFAULT 'N',
  P_RESPONSE_TYPE       IN VARCHAR2 DEFAULT NULL,
  P_DESCRIPTION         IN VARCHAR2 DEFAULT NULL,
  P_INSTRUCTION         IN VARCHAR2 DEFAULT NULL,
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
  X_OWNER               IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW  (
 P_COMPONENT_ID             IN NUMBER,
 P_COMPONENT_TYPE           IN VARCHAR2,
 P_COMPONENT_NAME           IN VARCHAR2,
 P_MANDATORY_FLAG           IN VARCHAR2,
 P_RESPONSE_TYPE            IN VARCHAR2,
 P_DESCRIPTION              IN VARCHAR2,
 P_INSTRUCTION              IN VARCHAR2,
 P_COMP_DISPLAY_SEQUENCE    IN NUMBER,
 P_COMP_SECTION_ID          IN NUMBER,
 P_PRESENTATION_STYLE       IN VARCHAR2,
 P_SECTION_COMPONENT_TYPE   IN VARCHAR2,
 P_Child_component_id       IN NUMBER,
 P_Sub_Section_id           IN NUMBER,
 P_Default_Response_id      IN NUMBER,
  p_context                  IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_UPLOAD_MODE              IN VARCHAR2,
  P_ATTRIBUTE1               IN VARCHAR2,
  P_ATTRIBUTE2               IN VARCHAR2,
  P_ATTRIBUTE3               IN VARCHAR2,
  P_ATTRIBUTE4               IN VARCHAR2,
  P_ATTRIBUTE5               IN VARCHAR2,
  P_ATTRIBUTE6               IN VARCHAR2,
  P_ATTRIBUTE7               IN VARCHAR2,
  P_ATTRIBUTE8               IN VARCHAR2,
  P_ATTRIBUTE9               IN VARCHAR2,
  P_ATTRIBUTE10              IN VARCHAR2,
  P_ATTRIBUTE11              IN VARCHAR2,
  P_ATTRIBUTE12              IN VARCHAR2,
  P_ATTRIBUTE13              IN VARCHAR2,
  P_ATTRIBUTE14              IN VARCHAR2,
  P_ATTRIBUTE15              IN VARCHAR2,
  P_ATTRIBUTE16              IN VARCHAR2,
  P_ATTRIBUTE17              IN VARCHAR2,
  P_ATTRIBUTE18              IN VARCHAR2,
  P_ATTRIBUTE19              IN VARCHAR2,
  P_ATTRIBUTE20              IN VARCHAR2
  );

END; -- Package Specification ASO_SUP_COMPONENT_PKG

 

/
