--------------------------------------------------------
--  DDL for Package Body FPA_GLOBAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_GLOBAL_PVT" AS
/* $Header: FPAVGLBB.pls 120.1 2005/08/18 11:49:19 appldev noship $ */

--fpa_aw := aw_space_name;

function aw_space_name return varchar2
is

  l_aw_space_name	varchar2(30);

begin

  SELECT application_short_name || '.fpapjp'
    into l_aw_space_name
    from FND_APPLICATION
   WHERE application_id = 440;

  return l_aw_space_name;

end aw_space_name;

FUNCTION is_aw_attached RETURN BOOLEAN
IS

	is_attached 	BOOLEAN;
	my_clob     	CLOB;
	buflen 		BINARY_INTEGER := 4;
	offset 		BINARY_INTEGER := 1;
	text_buffer 	VARCHAR2(200);
	position	NUMBER;
        l_aw_space_name	VARCHAR2(30);

BEGIN
  	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_global_pvt.is_aw_attached.begin',
			'Entering fpa_global_pvt.is_aw_attached'
		);
	END IF;

        l_aw_space_name := aw_space_name;

  	my_clob := dbms_aw.interp('show aw(attached ''' || l_aw_space_name || ''')');

  	dbms_lob.read(my_clob, buflen, offSet, text_buffer);

	position := instr(text_buffer, 'yes', 1);
	is_attached := position <> 0;

	IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_STATEMENT,
			'fpa.sql.fpa_global_pvt.is_aw_attached.begin',
			'Is AW attached: ' || text_buffer
		);
	END IF;

	IF (is_attached)
	THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
        END IF;
	IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		fnd_log.string
		(
			FND_LOG.LEVEL_PROCEDURE,
			'fpa.sql.fpa_global_pvt.is_aw_attached.end',
			'Exiting fpa_global_pvt.is_aw_attached'
		);
	END IF;
END;

END fpa_global_pvt;

/
