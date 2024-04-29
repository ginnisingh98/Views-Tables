--------------------------------------------------------
--  DDL for Package ECE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_UTILITIES" AUTHID CURRENT_USER AS
-- $Header: ECEUTILS.pls 120.3 2005/09/29 08:55:47 arsriniv ship $


PROCEDURE TEST_XREF_API (
        cDirection          IN     VARCHAR2,
	cTransaction_code   IN     VARCHAR2,
        cView_name          IN     VARCHAR2,
        cView_column        IN     VARCHAR2,
        cInternal_value     IN OUT NOCOPY VARCHAR2,
        cKey1_value         IN     VARCHAR2,
        cKey2_value         IN     VARCHAR2,
        cKey3_value         IN     VARCHAR2,
        cKey4_value         IN     VARCHAR2,
        cKey5_value         IN     VARCHAR2,
        cExt1_value         IN OUT NOCOPY VARCHAR2,
        cExt2_value         IN OUT NOCOPY VARCHAR2,
        cExt3_value         IN OUT NOCOPY VARCHAR2,
        cExt4_value         IN OUT NOCOPY VARCHAR2,
        cExt5_value         IN OUT NOCOPY VARCHAR2);

PROCEDURE SEED_DATA_CHECK (
	cTransaction_code   IN     VARCHAR2,
	bErrors_found	    OUT    NOCOPY BOOLEAN,
        iRun_id		    OUT    NOCOPY NUMBER,
	bCheckLength	    IN     BOOLEAN DEFAULT FALSE,
	bCheckDatatype      IN     BOOLEAN DEFAULT FALSE,
	bInsertErrors	    IN     BOOLEAN DEFAULT FALSE);

PROCEDURE TEST_TP_LOOKUP (
		p_Entity_site_id	IN	NUMBER,
		p_Entity_type		IN	VARCHAR2,
		p_location_code		OUT NOCOPY	VARCHAR2,
		p_reference_ext1	OUT NOCOPY	VARCHAR2,
		p_reference_ext2	OUT NOCOPY	VARCHAR2);


PROCEDURE TEST_LOCATION_CODE (
	p_Translator_code	IN	VARCHAR2,
	p_Location_code		IN	VARCHAR2,
	p_Entity_type		IN	VARCHAR2,
	l_entity_id	     	OUT	NOCOPY NUMBER,
	l_entity_address_id  	OUT	NOCOPY NUMBER);

PROCEDURE verify_flatfile(
      p_run_id           IN NUMBER,
      p_map_id		 IN NUMBER,
      p_Transaction_Type IN VARCHAR2,
      p_File_path        IN VARCHAR2,
      p_Filename         IN VARCHAR2);

PROCEDURE set_installation(
      p_transaction     IN VARCHAR2,
      p_short_name      IN VARCHAR2,
      p_status          IN VARCHAR2);


end ECE_UTILITIES;


 

/
