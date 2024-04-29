--------------------------------------------------------
--  DDL for Package INV_GEN_LOC_KFV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GEN_LOC_KFV" AUTHID CURRENT_USER AS
  /* $Header: INVLKFFS.pls 120.1.12000000.1 2007/01/17 16:19:49 appldev ship $ */

--Return values for x_retcode(standard for concurrent programs)
	RETCODE_SUCCESS  CONSTANT VARCHAR2(1)  := '0';
	RETCODE_WARNING  CONSTANT VARCHAR2(1)  := '1';
	RETCODE_ERROR    CONSTANT VARCHAR2(1)  := '2';

-- This regenerates WMS_ITEM_LOCATIONS_KFV with new Segment definitions if any.
PROCEDURE GENERATE_LOCATOR_KFF_VIEW(x_errbuf	      OUT NOCOPY VARCHAR2
                                    ,x_retcode	      OUT NOCOPY NUMBER
                                    ,p_compatibility  IN VARCHAR2) ;  --Added for bug#4345239
END INV_GEN_LOC_KFV;

 

/
