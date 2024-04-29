--------------------------------------------------------
--  DDL for Package Body IGI_ITR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR" AS
-- $Header: igiitrgb.pls 120.3.12000000.1 2007/09/12 10:31:04 mbremkum ship $
--
PROCEDURE action (p_action NUMBER)
AS
BEGIN
    l_Action     := l_Action + p_action;
END action;
--
--
PROCEDURE set_batches (p_batch_id NUMBER)
AS
BEGIN
    l_TableRow     := l_TableRow + 1;
    l_BatchIdTable(l_TableRow) := p_batch_id;
END set_batches;
--
--
PROCEDURE process_batches
AS
  l_Var     binary_integer := 0;
BEGIN
    IF l_Action <> 0
    THEN
       FOR I in 1..l_TableRow
       LOOP
          l_Var := l_Var + 1;
          IGI_itr.STATUS(l_BatchIdTable(l_Var));
       END LOOP;
    END IF;
END process_batches;
--
--
PROCEDURE control ( p_interface_run_id NUMBER
                  , p_group_id         NUMBER
                  , p_set_of_books_id  NUMBER
                  , p_status_code      IN OUT NOCOPY NUMBER
                  , p_status_message   IN OUT NOCOPY VARCHAR2
                  )
AS
import_request_id number;

BEGIN
    INSERT INTO gl_interface_control ( je_source_name
                                     , status
                                     , interface_run_id
                                     , group_id
                                     , set_of_books_id
                                     )
    VALUES ( 'Internal Trading'
           , 'S'
           , p_interface_run_id
           , p_group_id
           , p_set_of_books_id
           );

import_request_id := FND_REQUEST.SUBMIT_REQUEST
			('SQLGL'
			, 'GLLEZL'
			, NULL
			, NULL
			, FALSE
			, p_interface_run_id
			, p_set_of_books_id
			, 'N'
			, null
			, null
			, 'N'
			, 'N');
		p_status_code := import_request_id;
		if p_status_code > 0 then
--  p_status_message := 'The Import Request Id is '||to_char(import_request_id);
--  Modified by Prerak Vora for NLS Fixing.
              p_status_message := IGI_GEN.GET_LOOKUP_MEANING('IGI_IMPORT_REQUEST_ID');
	   p_status_message := p_status_message ||to_char(import_request_id);
-- Modification ends.
	commit;
       	elsif p_status_code = 0 then
-- Modified by Prerak Vora for NLS Fixing.
        p_status_message := IGI_GEN.GET_LOOKUP_MEANING('IGI_IMPORT_REQUEST_ID_FAIL');
--   p_status_message := 'The Import Request Failed';
		rollback;
		end if;
exception
	when others then
	p_status_code := -1;
	p_status_message := substr(sqlerrm,1,70);
	rollback;
END control;


PROCEDURE SUBMIT
(P_IT_HEADER_ID number,
 P_STATUS_FLAG IN OUT NOCOPY number, P_STATUS_MESSAGE IN OUT NOCOPY VARCHAR2)
AS

R_igi_itr_charge_headers IGI_itr_charge_headers%ROWTYPE;
R_igi_itr_charge_lines IGI_itr_charge_lines%ROWTYPE;

m_user_je_category_name varchar2(25);
m_user_je_source_name   varchar2(25);
interface_sequence_num number;
interface_group_id number;
import_request_id number;
m_submit_flag char;
dr_total number := 0;
cr_total number := 0;
flag number := 0;

CURSOR c1 is
SELECT *
FROM IGI_itr_charge_lines
WHERE it_header_id = p_it_header_id
  AND status_flag is null
  AND posting_flag is null;


BEGIN
    SELECT submit_flag into m_submit_flag
    FROM IGI_itr_charge_headers
    WHERE it_header_id = p_it_header_id;

    SELECT * into R_igi_itr_charge_headers
    FROM IGI_itr_charge_headers
    WHERE it_header_id = p_it_header_id;

    SELECT user_je_source_name into m_user_je_source_name
    FROM gl_je_sources
    WHERE je_source_name = R_igi_itr_charge_headers.it_source;

    SELECT user_je_category_name into m_user_je_category_name
    FROM gl_je_categories
    WHERE je_category_name = R_igi_itr_charge_headers.it_category;

    IF (m_submit_flag = 'S' or m_submit_flag = 'R') THEN
	SELECT gl_journal_import_s.nextval
	INTO interface_group_id
	FROM dual;
	INSERT INTO gl_interface
		(status
		,entered_dr
		,entered_cr
		,set_of_books_id
		,user_je_source_name
		,user_je_category_name
		,accounting_date
		,currency_code
		,date_created
		,created_by
		,actual_flag
		,encumbrance_type_id
		,code_combination_id
		,reference1
		,reference4
		,reference5
		,reference10
		,reference21
		,reference22
		,group_id
		)
	VALUES	('NEW'
		,R_igi_itr_charge_headers.entered_dr
		,R_igi_itr_charge_headers.entered_cr
		,R_igi_itr_charge_headers.set_of_books_id
		,m_user_je_source_name
		,m_user_je_category_name
		,R_igi_itr_charge_headers.gl_date
		,R_igi_itr_charge_headers.currency_code
		,R_igi_itr_charge_headers.creation_date
		,R_igi_itr_charge_headers.created_by
		,'E'
		,R_igi_itr_charge_headers.encumbrance_type_id
		,R_igi_itr_charge_headers.code_combination_id
		,R_igi_itr_charge_headers.name
		,R_igi_itr_charge_headers.name
		,R_igi_itr_charge_headers.description
		,R_igi_itr_charge_headers.description
		,R_igi_itr_charge_headers.it_header_id
		,NULL
		,interface_group_id
		);
        OPEN c1;
	 LOOP
		FETCH c1 INTO R_igi_itr_charge_lines;
		EXIT WHEN c1%NOTFOUND;

		INSERT INTO gl_interface
			(status
			,entered_dr
			,entered_cr
			,set_of_books_id
			,user_je_source_name
			,user_je_category_name
			,accounting_date
			,currency_code
			,date_created
			,created_by
			,actual_flag
			,encumbrance_type_id
			,code_combination_id
			,reference1
			,reference4
			,reference5
			,reference10
			,reference21
			,reference22
			,group_id
			)
		VALUES	('NEW'
			,R_igi_itr_charge_lines.entered_dr
			,R_igi_itr_charge_lines.entered_cr
			,R_igi_itr_charge_lines.set_of_books_id
			,m_user_je_source_name
			,m_user_je_category_name
			,R_igi_itr_charge_headers.gl_date
			,R_igi_itr_charge_headers.currency_code
			,R_igi_itr_charge_lines.creation_date
			,R_igi_itr_charge_lines.created_by
			,'E'
			,R_igi_itr_charge_headers.encumbrance_type_id
			,R_igi_itr_charge_lines.code_combination_id
			,R_igi_itr_charge_headers.name
			,R_igi_itr_charge_headers.name
			,R_igi_itr_charge_headers.description
			,R_igi_itr_charge_lines.description
			,R_igi_itr_charge_headers.it_header_id
			,R_igi_itr_charge_lines.it_line_num
			,interface_group_id
			);
	 END LOOP;
	CLOSE c1;
END IF;

SELECT gl_journal_import_s.nextval
INTO interface_sequence_num
FROM dual;

INSERT INTO gl_interface_control
		(je_source_name
		,status
		,interface_run_id
		,group_id
		,set_of_books_id)
VALUES
		('Internal Trading'
		,'S'
		,interface_sequence_num
		,interface_group_id
		,R_igi_itr_charge_headers.set_of_books_id
		);

import_request_id := FND_REQUEST.SUBMIT_REQUEST
			('SQLGL'
			, 'GLLEZL'
			, NULL
			, NULL
			, FALSE
			, interface_sequence_num
			,R_igi_itr_charge_headers.set_of_books_id
			, 'N'
			, null
			, null
			, 'N'
			, 'N');
p_status_flag := import_request_id;
IF p_status_flag > 0    THEN
   p_status_message := 'The Import Request Id is : '||to_char(import_request_id);
   COMMIT;
ELSIF p_status_flag = 0 THEN
   p_status_message := 'The Import Request Failed';
   ROLLBACK;
END IF;
EXCEPTION
	WHEN others THEN
	P_STATUS_FLAG := -1;
	P_STATUS_MESSAGE := substr(sqlerrm,1,70);
END SUBMIT;

/*Procedure ACCEPT */
procedure ACCEPT
(p_it_header_id number
,p_it_line_num number
,p_igig_itr_encumbrance_allowed char
,p_group_id number
,p_status_code in out NOCOPY number
,p_status_message in out NOCOPY char
) as


m_user_je_category_name varchar2(25);
m_user_je_source_name   varchar2(25);

R_header igi_itr_charge_headers%rowtype;
R_line igi_itr_charge_lines%rowtype;

PROCEDURE ACTUAL is
begin
insert into gl_interface
		(status
		,entered_dr
		,entered_cr
		,set_of_books_id
		,user_je_source_name
		,user_je_category_name
		,accounting_date
		,currency_code
		,date_created
		,created_by
		,actual_flag
		,encumbrance_type_id
		,code_combination_id
		,reference1
		,reference4
		,reference5
		,reference10
		,reference21
		,reference22
		,group_id
		)
	values	('NEW'
		,R_line.entered_dr
		,R_line.entered_cr
		,R_line.set_of_books_id
		,m_user_je_source_name
		,m_user_je_category_name
		,R_header.gl_date
		,R_header.currency_code
		,R_line.creation_date
		,R_line.created_by
		,'A'
		,null
		,R_line.code_combination_id
		,R_header.name
		,R_header.name
		,R_header.description
		,R_line.description
		,p_it_header_id
		,p_it_line_num
		,p_group_id
	        );
	insert into gl_interface
		(status
		,entered_dr
		,entered_cr
		,set_of_books_id
		,user_je_source_name
		,user_je_category_name
		,accounting_date
		,currency_code
		,date_created
		,created_by
		,actual_flag
		,encumbrance_type_id
		,code_combination_id
		,reference1
		,reference4
		,reference5
		,reference10
		,reference21
		,reference22
		,group_id
		)
	values	('NEW'
		,R_line.entered_cr
		,R_line.entered_dr
		,R_header.set_of_books_id
		,m_user_je_source_name
		,m_user_je_category_name
		,R_header.gl_date
		,R_header.currency_code
		,R_header.creation_date
		,R_header.created_by
		,'A'
		,null
		,R_header.code_combination_id
		,R_header.name
		,R_header.name
		,R_header.description
		,R_header.description
		,p_it_header_id
		,p_it_line_num
		,p_group_id
		);
end;
begin
	select * into R_header
	from IGI_itr_charge_headers
	where it_header_id  = p_it_header_id;

	select * into R_line
	from IGI_itr_charge_lines
	where it_header_id  = p_it_header_id
	and it_line_num = p_it_line_num;

	select user_je_source_name into m_user_je_source_name
	from gl_je_sources
	where je_source_name = R_header.it_source;

	select user_je_category_name into m_user_je_category_name
        from gl_je_categories
	where je_category_name = R_header.it_category;

	if (p_igig_itr_encumbrance_allowed = 'Y') then

	IGI_ITR.REJECT(R_header.it_header_id
			,R_line.it_line_num
			,p_group_id
			,p_status_code
			,p_status_message
			);
	ACTUAL;
	elsif (p_igig_itr_encumbrance_allowed = 'N') then
	ACTUAL;
	end if;
	EXCEPTION
	when others then
	p_status_code := sqlcode;
	p_status_message := substr(sqlerrm,1,70);
end ACCEPT;

/* Procedure REJECT */
procedure REJECT
(p_it_header_id number
,p_it_line_num number
,p_group_id number
,p_status_code in out NOCOPY number
,p_status_message in out NOCOPY char
) as


m_user_je_category_name varchar2(25);
m_user_je_source_name   varchar2(25);

R_header IGI_itr_charge_headers%rowtype;
R_line IGI_itr_charge_lines%rowtype;

begin
	select * into R_header
	from IGI_itr_charge_headers
	where it_header_id  = p_it_header_id;

	select * into R_line
	from IGI_itr_charge_lines
	where it_header_id  = p_it_header_id
	and it_line_num = p_it_line_num;

	select user_je_source_name into m_user_je_source_name
	from gl_je_sources
	where je_source_name = R_header.it_source;

	select user_je_category_name into m_user_je_category_name
        from gl_je_categories
	where je_category_name = R_header.it_category;

	insert into gl_interface
		(status
		,entered_dr
		,entered_cr
		,set_of_books_id
		,user_je_source_name
		,user_je_category_name
		,accounting_date
		,currency_code
		,date_created
		,created_by
		,actual_flag
		,encumbrance_type_id
		,code_combination_id
		,reference1
		,reference4
		,reference5
		,reference10
		,reference21
		,reference22
		,group_id
		)
	values	('NEW'
		,R_line.entered_cr
		,R_line.entered_dr
		,R_line.set_of_books_id
		,m_user_je_source_name
		,m_user_je_category_name
		,R_header.gl_date
		,R_header.currency_code
		,R_line.creation_date
		,R_line.created_by
		,'E'
		,R_header.encumbrance_type_id
		,R_line.code_combination_id
		,R_header.name
		,R_header.name
		,R_header.description
		,R_line.description
		,p_it_header_id
		,p_it_line_num
		,p_group_id
	        );
	insert into gl_interface
		(status
		,entered_dr
		,entered_cr
		,set_of_books_id
		,user_je_source_name
		,user_je_category_name
		,accounting_date
		,currency_code
		,date_created
		,created_by
		,actual_flag
		,encumbrance_type_id
		,code_combination_id
		,reference1
		,reference4
		,reference5
		,reference10
		,reference21
		,reference22
		,group_id
		)
	values	('NEW'
		,R_line.entered_dr
		,R_line.entered_cr
		,R_header.set_of_books_id
		,m_user_je_source_name
		,m_user_je_category_name
		,R_header.gl_date
		,R_header.currency_code
		,R_header.creation_date
		,R_header.created_by
		,'E'
		,R_header.encumbrance_type_id
		,R_header.code_combination_id
		,R_header.name
		,R_header.name
		,R_header.description
		,R_header.description
		,p_it_header_id
		,p_it_line_num
		,p_group_id
		);
EXCEPTION
	when others then
	p_status_code := sqlcode;
	p_status_message := substr(sqlerrm,1,70);
end REJECT;

/*
 *   STATUS
 */
procedure STATUS( p_batch_id number) as

b_budgetary_control_status gl_je_batches.budgetary_control_status%TYPE;
b_status_flag gl_je_batches.status%TYPE;
l_status_flag varchar2(1);
l_posting_flag varchar2(1);
b_actual_flag varchar2(1);
a number;

cursor c_header(c_batch_id number) is
select je_header_id
from gl_je_headers
where je_batch_id = c_batch_id
  and je_source = 'Internal Trading';

cursor c_line(c_header_id number)
is select reference_1,reference_2
from gl_je_lines
where je_header_id = c_header_id;

begin
select budgetary_control_status, status,actual_flag into
b_budgetary_control_status, b_status_flag , b_actual_flag
from gl_je_batches
where je_batch_id = p_batch_id;

   for current_header in c_header(p_batch_id) loop

        for current_line in c_line(current_header.je_header_id) loop
	 begin
	  if (current_line.reference_1 is not null) and
	     (current_line.reference_2 is not null) then
           select status_flag, posting_flag  into l_status_flag, l_posting_flag
            from IGI_itr_charge_lines
            where it_header_id = current_line.reference_1 and
                  it_line_num  = current_line.reference_2;
	  else
                select 1 into a from IGI_itr_charge_headers
		where it_header_id = current_line.reference_1;
		l_status_flag := NULL;
	  end if;
	EXCEPTION
       when no_data_found then
           exit;
        end;

   if b_status_flag NOT IN('P','S','U','I' )
   then
      if b_budgetary_control_status = 'F'
      then
         if l_status_flag IS NULL
         then
            UPDATE IGI_itr_charge_headers
            SET    submit_flag = 'F'
            WHERE  it_header_id = current_line.reference_1;
         else
            UPDATE IGI_itr_charge_lines
            SET    posting_flag = 'F'
            WHERE  it_header_id = current_line.reference_1
            AND    it_line_num  = current_line.reference_2;
         end if;

	 DELETE gl_je_lines where je_header_id IN
		 ( SELECT je_header_id
                   FROM   gl_je_headers
		   WHERE  je_batch_id = p_batch_id
                 );
	 DELETE gl_je_headers WHERE je_batch_id = p_batch_id;
	 DELETE gl_je_batches WHERE je_batch_id = p_batch_id;


      elsif b_budgetary_control_status = 'R'
      and   b_status_flag in ('D','Z')

      then
         if l_status_flag IS NULL
         then
            UPDATE IGI_itr_charge_headers
            SET submit_flag = 'D'
            WHERE it_header_id = current_line.reference_1;
      else
            UPDATE IGI_itr_charge_lines
            SET    posting_flag = 'D'
            WHERE  it_header_id = current_line.reference_1
            AND it_line_num = current_line.reference_2;
      end if;

      DELETE gl_je_lines where je_header_id IN
              (SELECT je_header_id
               FROM gl_je_headers
               WHERE je_batch_id = p_batch_id);
      delete gl_je_headers where je_batch_id = p_batch_id;
      delete gl_je_batches where je_batch_id = p_batch_id;


      elsif  b_budgetary_control_status NOT IN ('R')
      and    b_status_flag in ('D','Z')

      then
         if l_status_flag IS NULL
         then
            UPDATE IGI_itr_charge_headers
            SET    submit_flag = 'O'
            WHERE  it_header_id = current_line.reference_1;
         else
            UPDATE IGI_itr_charge_lines
            SET    posting_flag = 'O'
            WHERE  it_header_id = current_line.reference_1
            AND    it_line_num  = current_line.reference_2;
         end if;

/*	 DELETE gl_je_lines where je_header_id IN
		 ( SELECT je_header_id
                   FROM   gl_je_headers
		   WHERE  je_batch_id = p_batch_id
                 );
	 DELETE gl_je_headers WHERE je_batch_id = p_batch_id;
	 DELETE gl_je_batches WHERE je_batch_id = p_batch_id;
*/
      elsif b_budgetary_control_status = 'N'
      then
         if l_status_flag IS NULL
         then
            UPDATE IGI_itr_charge_headers
            SET    submit_flag = 'D'
            WHERE  it_header_id = current_line.reference_1;
         else
            UPDATE IGI_itr_charge_lines
            SET    posting_flag = 'D'
            WHERE  it_header_id = current_line.reference_1
            AND    it_line_num  = current_line.reference_2;
         end if;

	 DELETE gl_je_lines where je_header_id IN
		 ( SELECT je_header_id
                   FROM   gl_je_headers
		   WHERE  je_batch_id = p_batch_id
                 );
	 DELETE gl_je_headers WHERE je_batch_id = p_batch_id;
	 DELETE gl_je_batches WHERE je_batch_id = p_batch_id;

      elsif b_budgetary_control_status = 'P'
      then
         if l_status_flag IS NULL
         then
            UPDATE IGI_itr_charge_headers
            SET    submit_flag = 'O'
            WHERE  it_header_id = current_line.reference_1;
         else
            UPDATE IGI_itr_charge_lines
            SET    posting_flag = 'O'
            WHERE  it_header_id = current_line.reference_1
            AND    it_line_num  = current_line.reference_2;
         end if;
      else
         NULL;
      end if;

   elsif b_status_flag = 'P'
   then
      if l_status_flag IS NULL
      then
         UPDATE IGI_itr_charge_headers
         SET    submit_flag = 'P'
         WHERE  it_header_id = current_line.reference_1;
      else
       if  (l_posting_flag = 'S' OR l_posting_flag = 'P')
	then
         UPDATE IGI_itr_charge_lines
         SET    posting_flag = 'P'
         WHERE  it_header_id = current_line.reference_1
         AND    it_line_num  = current_line.reference_2;

	UPDATE IGI_itr_charge_headers
	set submit_flag = 'C' where
	it_header_id = current_line.reference_1
	and ('A','P') =all (select status_flag,posting_flag
	from IGI_itr_charge_lines
	where it_header_id = current_line.reference_1)
	AND b_actual_flag = 'A';
       end if;
      end if;
   else
      NULL;
   end if;


	end loop;
end loop;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
end STATUS;

end IGI_ITR;

/
