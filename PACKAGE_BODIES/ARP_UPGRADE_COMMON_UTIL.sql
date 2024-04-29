--------------------------------------------------------
--  DDL for Package Body ARP_UPGRADE_COMMON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_UPGRADE_COMMON_UTIL" AS
/* $Header: ARUPGCOB.pls 115.5 2002/12/18 18:47:40 snambiar ship $*/
--

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PRIVATE VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/
pg_file_name    VARCHAR2(100) := NULL;
pg_path_name    VARCHAR2(100) := NULL;
pg_fp           utl_file.file_type;

debug_flag boolean := false;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into AR_DISTRIBUTIONS_ALL table, inserts org_id       |
 |    column for Multi Org.                                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_dist_rec        - Distribution record to be inserted                 |
 |                                                                           |
 |    OUT:                                                                   |
 |    p_line_id         - Line Id of the distribution created                |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    07-DEC-98 VAHLUWAL        Created for Release 11.5 upgrade             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_p( p_dist_rec 	IN ar_distributions_all%ROWTYPE,
	            p_line_id	OUT NOCOPY ar_distributions_all.line_id%TYPE ) IS

l_line_id	ar_distributions_all.line_id%TYPE;

BEGIN
      --
      SELECT ar_distributions_s.nextval
      INTO   l_line_id
      FROM   dual;
      --

      INSERT INTO  ar_distributions_all (
		   line_id,
		   source_id,
 		   source_table,
 		   source_type,
 		   code_combination_id,
 		   amount_dr,
 		   amount_cr,
 		   acctd_amount_dr,
 		   acctd_amount_cr,
 		   created_by,
 		   creation_date,
 		   last_updated_by,
 		   last_update_date,
                   last_update_login,
                   source_id_secondary,
                   source_table_secondary,
                   currency_code        ,
                   currency_conversion_rate,
                   currency_conversion_type,
                   currency_conversion_date,
                   third_party_id,
                   third_party_sub_id,
                   tax_code_id,
                   location_segment_id,
                   reversed_source_id,
                   taxable_entered_dr,
                   taxable_entered_cr,
                   taxable_accounted_dr,
                   taxable_accounted_cr,
                   tax_link_id,
                   org_id
 		 )
       VALUES (    l_line_id,
                   p_dist_rec.source_id,
                   p_dist_rec.source_table,
                   p_dist_rec.source_type,
                   p_dist_rec.code_combination_id,
                   p_dist_rec.amount_dr,
                   p_dist_rec.amount_cr,
                   p_dist_rec.acctd_amount_dr,
                   p_dist_rec.acctd_amount_cr,
		   -2001,                       --identifies that AR Upgrade created the data
 		   SYSDATE,
		   -2001,
 		   SYSDATE,
		   -2001,
                   p_dist_rec.source_id_secondary,
                   p_dist_rec.source_table_secondary,
                   p_dist_rec.currency_code        ,
                   p_dist_rec.currency_conversion_rate,
                   p_dist_rec.currency_conversion_type,
                   p_dist_rec.currency_conversion_date,
                   p_dist_rec.third_party_id,
                   p_dist_rec.third_party_sub_id,
                   p_dist_rec.tax_code_id,
                   p_dist_rec.location_segment_id,
                   p_dist_rec.reversed_source_id,
                   p_dist_rec.taxable_entered_dr,
                   p_dist_rec.taxable_entered_cr,
                   p_dist_rec.taxable_accounted_dr,
                   p_dist_rec.taxable_accounted_cr,
                   p_dist_rec.tax_link_id,
                   p_dist_rec.org_id
	       );

    p_line_id := l_line_id;

    EXCEPTION
	WHEN OTHERS THEN
	    debug( 'EXCEPTION: ARP_UPGRADE_COMMON_UTIL.insert_p' );
	    RAISE;

END insert_p;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    file_debug                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Actual procedure which writes message using file handler.              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_line            - Message to be written to file                      |
 |                                                                           |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    07-DEC-98 VAHLUWAL        Created for Release 11.5 upgrade             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE file_debug(p_line in varchar2) IS
x number;

BEGIN

  IF (pg_file_name IS NOT NULL) THEN

    utl_file.put_line(pg_fp, p_line);
    utl_file.fflush(pg_fp);

  END IF;

EXCEPTION  --we only write using the io file so theres not much that can be done other than exception
   WHEN OTHERS THEN
        RAISE;

END file_debug;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    enable_file_debug                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Opens file to which debug messages are written.                        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_path_name       - Path in which file will be created                 |
 |    p_file_name       - File name to which messages are written            |
 |                                                                           |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    07-DEC-98 VAHLUWAL        Created for Release 11.5 upgrade             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE enable_file_debug(p_path_name in varchar2,
                            p_file_name in varchar2) IS
x number;
BEGIN

  IF (pg_file_name is null) THEN

    pg_fp := utl_file.fopen(p_path_name, p_file_name, 'w');
    pg_file_name := p_file_name;
    pg_path_name := p_path_name;

  END IF;

EXCEPTION  -- always raise exception as cannot write to file
     WHEN OTHERS THEN
        RAISE;
END;

PROCEDURE disable_file_debug IS
BEGIN

  IF (pg_file_name IS NOT NULL) THEN
    utl_file.fclose(pg_fp);
  END IF;

EXCEPTION  -- always raise exception as cannot write to file
     WHEN OTHERS THEN
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    debug                                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function which writes specific message to a file                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_line            - Message string                                     |
 |                                                                           |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    07-DEC-98 VAHLUWAL        Created for Release 11.5 upgrade             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE debug(p_line in varchar2) IS

l_rest VARCHAR2(32767);

BEGIN

    IF (pg_file_name IS NOT NULL) THEN
      file_debug(p_line);
    ELSE
      if debug_flag then
        l_rest := p_line;
        loop
            if( l_rest is null ) then
                exit;
            else
                l_rest := substrb(l_rest, 256);
            end if;

        end loop;
      end if;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END;

procedure enable_debug is
begin
   debug_flag := true;
end;

procedure enable_debug( buffer_size NUMBER ) is
begin
   debug_flag := true;
end;

procedure disable_debug is
begin
   debug_flag := false;
end;

--
END ARP_UPGRADE_COMMON_UTIL;

/
