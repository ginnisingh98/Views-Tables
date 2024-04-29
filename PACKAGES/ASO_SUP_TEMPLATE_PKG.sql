--------------------------------------------------------
--  DDL for Package ASO_SUP_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_SUP_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/* $Header: asosptms.pls 120.1.12010000.2 2015/02/09 09:38:16 akushwah ship $*/

-- Purpose: To Insert/Update/delete data for ASO_SUP_TEMPLATE_B and ASO_SUP_TEMPLATE_TL table for HTML Quoting
-- File name asosptms.pls


-- MODIFICATION HISTORY
-- Person            Date          Comments
-- ---------         ------        ------------------------------------------
--  Sarala Biswal    01/17/02      Created Package
--  Suyog Kulkarni   04/30/03      Added Column Template_Level to table handlers for ASO_SUP_TEMPLATE_B
--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 1.
    	-- Start of comments
	--   API name        : INSERT_ROW
    --   Purpose         : Procedure to insert into ASO_SUP_TEMPLATE_B and  ASO_SUP_TEMPLATE_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              : P_TEMPLATE_NAME          IN    VARCHAR2            Required


	--   IN OUT NOCOPY /* file.sql.39 change */          : PX_TEMPLATE_ID           IN OUT NUMBER
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------


PROCEDURE INSERT_ROW
(
  PX_ROWID              IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  PX_TEMPLATE_ID        IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME       IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2 DEFAULT NULL,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  P_ATTRIBUTE20         IN VARCHAR2 DEFAULT NULL
);


--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 2.
    	-- Start of comments
	--   API name        : UPDATE_ROW
    --   Purpose         : Procedure to update ASO_SUP_TEMPLATE_B and  ASO_SUP_TEMPLATE_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --  		       P_TEMPLATE_ID            IN    NUMBER              Required
        --                 P_TEMPLATE_NAME         IN    VARCHAR2            Required
	--   OUT NOCOPY /* file.sql.39 change */             : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------



PROCEDURE UPDATE_ROW
(
  P_TEMPLATE_ID        IN NUMBER,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME       IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  P_ATTRIBUTE20         IN VARCHAR2

);



--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
	-- 3.
    	-- Start of comments
	--   API name        : DELETE_ROW
    --   Purpose         : Procedure to delete from ASO_SUP_TEMPLATE_B and  ASO_SUP_TEMPLATE_TL table
	--   Type            : Private
	--   Pre-reqs        : None
	--   Parameters      :
	--   IN              :
        --  		       P_TEMPLATE_ID       IN    NUMBER              Required

	--   OUT NOCOPY /* file.sql.39 change */             : None
	--   Version         :
	--                     Current version      1.0
	--                     Previous version     1.0
	--                     Initial version      1.0
	-- End of comments
--------------------------------------------------------------------------------------

procedure DELETE_ROW (
  P_TEMPLATE_ID IN NUMBER

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
	--   IN              : P_TEMPLATE_ID           IN    NUMBER              Required
        --  		       P_TEMPLATE_NAME         IN    VARCHAR2            Optional
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
  P_TEMPLATE_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME       IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  -- Start : code change done for Bug 20470801
  P_ATTRIBUTE16		IN VARCHAR2,
  P_ATTRIBUTE17		IN VARCHAR2,
  P_ATTRIBUTE18		IN VARCHAR2,
  P_ATTRIBUTE19		IN VARCHAR2,
  P_ATTRIBUTE20		IN VARCHAR2
  -- End : code change done for Bug 20470801

);


procedure ADD_LANGUAGE;


procedure TRANSLATE_ROW (
   P_TEMPLATE_ID IN NUMBER,
   P_TEMPLATE_NAME IN VARCHAR2,
   P_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2);

procedure LOAD_ROW (
  P_TEMPLATE_ID        IN NUMBER,
  P_created_by          IN NUMBER ,
  P_creation_date       IN DATE ,
  P_last_updated_by     IN NUMBER,
  P_last_update_date    IN DATE,
  P_last_update_login   IN NUMBER,
  P_TEMPLATE_NAME      IN VARCHAR2,
  P_DESCRIPTION         IN VARCHAR2,
  P_TEMPLATE_LEVEL      IN VARCHAR2,
  P_TEMPLATE_CONTEXT    IN VARCHAR2,
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
  X_OWNER               IN VARCHAR2);

  Procedure LOAD_SEED_ROW (
  PX_TEMPLATE_ID             IN NUMBER ,
  P_TEMPLATE_NAME            IN VARCHAR2,
  P_DESCRIPTION              IN VARCHAR2,
  P_TEMPLATE_LEVEL           IN VARCHAR2,
  P_TEMPLATE_CONTEXT         IN VARCHAR2,
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

END; -- Package Specification ASO_SUP_TEMPLATE_PKG

/
