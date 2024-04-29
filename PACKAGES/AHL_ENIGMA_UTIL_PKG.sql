--------------------------------------------------------
--  DDL for Package AHL_ENIGMA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_ENIGMA_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUENGS.pls 120.0.12010000.1 2008/11/05 14:13:54 sathapli noship $ */

   ---------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: get_enigma_url_params
	--  Function				: Returns the Model of MC header, ATA Code of the position and Tail Number of the unit
	--  get_enigma_url_params Parameters:
   --       p_object_type           : Indicates whether the call is from MC or UC context
   --			p_primary_object_id     : Incase of MC this will be the Relationship Id, For UC this will be the instance Id
	--			p_secondary_object_id   : Incase of MC this will be null, incase of UC if p_primary_object_id if is null this will be
   --                                 uc header id
   --       x_model                 : The model of the corresponding MC
   --       x_ata_code              : The ATA Code of the corresponding position
   --       x_tail_number           : The tail number of the corresponding UC
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
PROCEDURE get_enigma_url_params(
         p_object_type              IN    VARCHAR2,
         p_primary_object_id        IN    NUMBER ,
         p_secondary_object_id      IN    NUMBER ,
         x_model                    OUT   NOCOPY VARCHAR2,
         x_ata_code                 OUT   NOCOPY VARCHAR2,
         x_tail_number              OUT   NOCOPY VARCHAR2,
         x_user_name                OUT   NOCOPY VARCHAR2,
         x_user_lang                OUT   NOCOPY VARCHAR2,
         x_doc_ID                   OUT   NOCOPY VARCHAR2
);

FUNCTION IS_TASK_CARD_ENABLED (
                  p_workorder_id   IN    NUMBER)
RETURN VARCHAR2 ;



END AHL_ENIGMA_UTIL_PKG;

/
