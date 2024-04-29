--------------------------------------------------------
--  DDL for Package BIS_COLLECTION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COLLECTION_UTILITIES" AUTHID CURRENT_USER AS
/*$Header: BISDBUTS.pls 120.0 2005/06/01 16:41:26 appldev noship $*/

g_debug  		Boolean;

/* removed EDW_TRACE  and g_trace for bug3320661
g_trace  		Boolean;
*/

g_hash_area_size 	NUMBER;
g_sort_area_size 	NUMBER;
g_parallel       	NUMBER;
g_op_table_space 	dba_tablespaces.tablespace_name%TYPE;  --??? size
g_status 		boolean;
g_status_message 	varchar2(30000);
g_object_name  		varchar2(400);
g_start_date	 	date;
g_request_id     	number;
g_concurrent_id  	number;
g_user_id               PLS_INTEGER     := 0;
g_login_id              PLS_INTEGER     := 0;
g_space 		varchar2(30) := '                         ';
g_line 			varchar2(30)  := '-------------------------';
g_indenting 		varchar2(10) := '    ';
g_length_rate_type 	number := 12;
g_length_from_currency 	number := 17;
g_length_to_currency 	number := 15;
g_length_date 		number := 20;
g_length_from_to_uom 	number := 15;
g_length_inventory_item number := 19;

g_length_contract_no    number := 25;  --increased to 25 for bug 4105469
g_length_status		number := 15;
g_length_contract_id    number := 15;



FUNCTION SETUP(p_object_name IN VARCHAR2,
		p_parallel IN NUMBER default null) RETURN BOOLEAN;

PROCEDURE WRAPUP(
        p_status            IN   BOOLEAN,
        p_count             IN   NUMBER  default 0,
        p_message           IN   VARCHAR2  DEFAULT NULL,
        p_period_from       IN   DATE default null,
        p_period_to         IN   DATE default null,
        p_attribute1        IN   VARCHAR2 default null,
        p_attribute2        IN   VARCHAR2 default null,
        p_attribute3        IN   VARCHAR2 default null,
        p_attribute4        IN   VARCHAR2 default null,
        p_attribute5        IN   VARCHAR2 default null,
        p_attribute6        IN   VARCHAR2 default null,
        p_attribute7        IN   VARCHAR2 default null,
        p_attribute8        IN   VARCHAR2 default null,
        p_attribute9        IN   VARCHAR2 default null,
        p_attribute10       IN   VARCHAR2 default null);   --??? para type

PROCEDURE WRITE_BIS_REFRESH_LOG(
        p_status            IN   BOOLEAN,
        p_count             IN   NUMBER  default 0,
        p_message           IN   VARCHAR2  DEFAULT NULL,
        p_period_from       IN   DATE default null,
        p_period_to         IN   DATE default null,
        p_attribute1        IN   VARCHAR2 default null,
        p_attribute2        IN   VARCHAR2 default null,
        p_attribute3        IN   VARCHAR2 default null,
        p_attribute4        IN   VARCHAR2 default null,
        p_attribute5        IN   VARCHAR2 default null,
        p_attribute6        IN   VARCHAR2 default null,
        p_attribute7        IN   VARCHAR2 default null,
        p_attribute8        IN   VARCHAR2 default null,
        p_attribute9        IN   VARCHAR2 default null,
        p_attribute10       IN   VARCHAR2 default null);   --??? para type

function get_last_failure_period(p_object_name in varchar2) return varchar2;

/*
 *  Overloaded get_last_failure_period for bug#4365064 to return both period_to
 *  and p_period_from
 */
procedure get_last_failure_period(
  p_object_name in varchar2,
  p_period_from OUT NOCOPY varchar2,
  p_period_to   OUT NOCOPY varchar2
 );

function get_last_refresh_period(p_object_name in varchar2) return varchar2;

procedure get_last_refresh_dates(
p_object_name IN VARCHAR2,
p_start_date OUT NOCOPY DATE,
p_end_date OUT NOCOPY DATE,
p_period_from OUT NOCOPY DATE,
p_period_to OUT NOCOPY DATE
) ;

procedure get_last_user_attributes(
 p_object_name          IN VARCHAR2,
 p_attribute_table	OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
 p_count		OUT NOCOPY NUMBER );

procedure log(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER default 0) ;

procedure debug(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER default 0) ;

procedure out(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER default 0) ;

PROCEDURE put_names(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2);

PROCEDURE put_line(
                p_text			VARCHAR2) ;

PROCEDURE put_line_out(
                p_text			VARCHAR2);

Procedure writeMissingRateHeader;
FUNCTION  getMissingRateHeader return VARCHAR2;

Procedure writeMissingRate(
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2 default null);  /* Formatted date, will output this instead of p_date */

FUNCTION getMissingRateText(
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2 default null) return VARCHAR2;  /* Formatted date, will output this instead of p_date */

Procedure writeMissingContractHeader;

Procedure writeMissingContract(
P_contract_no IN VARCHAR2,	   /* Contract Number*/
P_contract_status IN VARCHAR2, /* Contract Status*/
p_contract_id IN VARCHAR2,
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2 default null/* Formatted date, will output this instead of p_date */
);


PROCEDURE deleteLogForObject(p_object_name IN VARCHAR2);
PROCEDURE enableParallelDML;
Procedure disableParallelDML;



PROCEDURE writeMissingUOMHeader;

PROCEDURE writeMissingUOM(
p_from_uom			IN VARCHAR2,  /* From UOM */
p_to_uom			IN VARCHAR2,  /* To UOM  */
p_inventory_item		IN VARCHAR2); /* Inventory Item ID */

/*
 * Added for FND_LOG uptaking
 */

PROCEDURE put_line(
p_text			VARCHAR2,
p_severity NUMBER) ;

procedure put_fnd_log(
p_text	IN VARCHAR2,
p_severity NUMBER) ;

PROCEDURE put_conc_log(p_text VARCHAR2);

procedure log(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER default 0,
p_severity NUMBER) ;

procedure debug(
p_message	IN VARCHAR2,
p_indenting	IN NUMBER default 0,
p_severity NUMBER) ;


END BIS_COLLECTION_UTILITIES;

 

/
