--------------------------------------------------------
--  DDL for Package Body GL_GLXRLSEG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLSEG_XMLP_PKG" AS
/* $Header: GLXRLSEGB.pls 120.0 2007/12/27 15:18:44 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
  colname VARCHAR2(30);
  value_set_id number;
  prompt  VARCHAR2(80);
  p_value_set_id number;
  p_prompt VARCHAR2(80);
  seg_type VARCHAR2(1);
  printswitch VARCHAR2(1);
  account_position number default 1;
  value_attribute_type VARCHAR2(30);

  CURSOR get_position (valset number) IS
    SELECT value_attribute_type
    FROM   FND_FLEX_VALIDATION_QUALIFIERS
    WHERE  id_flex_code = 'GL#'
    AND    id_flex_application_id = 101
    AND    flex_value_set_id = valset
    ORDER BY assignment_date, value_attribute_type;

begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
    COA_NAME := gl_flexfields_pkg.get_coa_name(P_STRUCT_NUM);

  exception
    when NO_DATA_FOUND then
      errbuf := gl_message.get_message('GL_PLL_ROUTINE_ERROR', 'N',
                   'ROUTINE','gl_flexfields_pkg.get_coa_name');
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  SELECT fs.flex_value_set_id, fs.application_column_name,
         fst.form_above_prompt
  into  value_set_id, colname, prompt
  from fnd_id_flex_segments fs, fnd_id_flex_segments_tl fst
  where fs.id_flex_code = 'GL#'
  and fs.enabled_flag = 'Y'
  and fs.id_flex_num = P_STRUCT_NUM
  and fs.segment_name = P_SEGMENT_NAME
  and fs.application_id = 101
  and fst.application_id = fs.application_id + 0
  and fst.id_flex_code = fs.id_flex_code
  and fst.id_flex_num = fs.id_flex_num
  and fst.application_column_name = fs.application_column_name
  and fst.language = userenv('LANG');

  select attribute_value
  into printswitch
  from fnd_segment_attribute_values
  where application_id = 101
  and  id_flex_code = 'GL#'
  and  id_flex_num = P_STRUCT_NUM
  and  segment_attribute_type = 'GL_ACCOUNT'
  and  application_column_name = colname;

  APROMPT := prompt;
  VSETID := value_set_id;
  APRINTSWITCH := printswitch;



  OPEN get_position(value_set_id);
  LOOP
    fetch get_position into value_attribute_type;
    exit when get_position%NOTFOUND;
    IF (value_attribute_type='GL_ACCOUNT_TYPE') THEN
      POSITION := account_position;
    END IF;
    IF (value_attribute_type = 'DETAIL_BUDGETING_ALLOWED') THEN
      BUDGET_POSITION := account_position;
    END IF;
    IF (value_attribute_type = 'DETAIL_POSTING_ALLOWED') THEN
      POST_POSITION := account_position;
    END IF;
    account_position := account_position + 1;
  END LOOP;
  CLOSE get_position;

  /*srw.message(100, 'HI'||value_set_id||'HI'||POSITION||'HI'||BUDGET_POSITION||'HI'||POST_POSITION);*/null;


  SELECT ffvs.validation_type
  INTO   seg_type
  FROM   fnd_flex_value_sets ffvs
  WHERE  ffvs.flex_value_set_id = value_set_id;

  if (seg_type = 'D') then
       select vs.parent_flex_value_set_id
       into  p_value_set_id
       from fnd_flex_value_sets vs
       where vs.flex_value_set_id = value_set_id;

       SELECT  distinct fst.form_above_prompt
       into  p_prompt
       from  fnd_id_flex_segments fs, fnd_id_flex_segments_tl fst
       where fs.application_id = 101
       and   fs.id_flex_code = 'GL#'
       and   fs.enabled_flag = 'Y'
       and   fs.id_flex_num = P_STRUCT_NUM
       and   fs.flex_value_set_id = p_value_set_id
       and   fst.application_id = fs.application_id + 0
       and   fst.id_flex_code = fs.id_flex_code
       and   fst.id_flex_num = fs.id_flex_num
       and   fst.application_column_name = fs.application_column_name
       and   fst.language = userenv('LANG');

       PAPROMPT := p_prompt;
       PVSETID := p_value_set_id;
    return (TRUE);
  end if;

  SEGMENT_TYPE := seg_type;

  RETURN (TRUE);
EXCEPTION
  when NO_DATA_FOUND then
    /*srw.message('00',SQLERRM);*/null;

end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function COA_NAME_p return varchar2 is
	Begin
	 return COA_NAME;
	 END;
 Function APROMPT_p return varchar2 is
	Begin
	 return APROMPT;
	 END;
 Function APRINTSWITCH_p return varchar2 is
	Begin
	 return APRINTSWITCH;
	 END;
 Function VSETID_p return number is
	Begin
	 return VSETID;
	 END;
 Function PAPROMPT_p return varchar2 is
	Begin
	 return PAPROMPT;
	 END;
 Function SEGMENT_TYPE_p return varchar2 is
	Begin
	 return SEGMENT_TYPE;
	 END;
 Function PVSETID_p return number is
	Begin
	 return PVSETID;
	 END;
 Function POSITION_p return number is
	Begin
	 return POSITION;
	 END;
 Function POST_POSITION_p return number is
	Begin
	 return POST_POSITION;
	 END;
 Function BUDGET_POSITION_p return number is
	Begin
	 return BUDGET_POSITION;
	 END;
END GL_GLXRLSEG_XMLP_PKG ;


/
