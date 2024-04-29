--------------------------------------------------------
--  DDL for Package HR_DU_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_UTILITY" AUTHID CURRENT_USER AS
/* $Header: perdutil.pkh 115.5 2002/11/28 17:09:21 apholt noship $ */


-- 11i / 11.0 specific code
-- start
FUNCTION local_chr(p_char_code IN NUMBER) RETURN VARCHAR2;

PROCEDURE dynamic_sql(p_string IN VARCHAR2);

PROCEDURE dynamic_sql_num(p_string IN VARCHAR2,
                          p_return_value IN OUT NOCOPY NUMBER);

PROCEDURE dynamic_sql_num_user_key(
                          p_string IN VARCHAR2,
		          p_api_module_id IN NUMBER,
        		  p_column_id IN NUMBER,
                          p_return_value IN OUT NOCOPY NUMBER);

PROCEDURE dynamic_sql_str(p_string IN VARCHAR2,
                          p_return_value IN OUT NOCOPY VARCHAR2,
                          p_string_length IN NUMBER);

FUNCTION chunk_size RETURN NUMBER;

-- 11i / 11.0 specific code
-- end




-- error procedures
-- start
PROCEDURE error (p_sqlcode IN NUMBER, p_procedure IN VARCHAR2,
                 p_extra IN VARCHAR2, p_rollback IN VARCHAR2 DEFAULT 'R');
-- error procedures
-- end


-- message procedures
-- start
PROCEDURE message (p_type IN VARCHAR2, p_message IN VARCHAR2,
                   p_position IN NUMBER);
PROCEDURE message_init;
-- message procedures
--end



-- update status procedures
-- start
PROCEDURE update_uploads (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_upload_lines (p_new_status IN VARCHAR2, p_id IN NUMBER);
PROCEDURE update_upload_headers (p_new_status IN VARCHAR2, p_id IN NUMBER);
-- update status procedures
-- end



-- general purpose procedures
-- start
FUNCTION get_uploads_status(p_upload_id IN NUMBER)
         RETURN VARCHAR2;
FUNCTION get_upload_headers_status(p_upload_header_id IN NUMBER)
         RETURN VARCHAR2;
FUNCTION get_upload_lines_status(p_upload_lines_id IN NUMBER)
         RETURN VARCHAR2;
-- general purpose procedures
-- end

FUNCTION Return_Spreadsheet_row(p_row_number IN NUMBER) RETURN VARCHAR2;


end hr_du_utility;

 

/
