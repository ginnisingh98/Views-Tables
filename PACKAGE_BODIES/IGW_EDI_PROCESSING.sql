--------------------------------------------------------
--  DDL for Package Body IGW_EDI_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_EDI_PROCESSING" as
/* $Header: igwecpob.pls 115.8 2002/11/14 18:44:33 vmedikon ship $ */



  PROCEDURE Submit (	errbuf 				IN OUT NOCOPY varchar2
			,retcode 			IN OUT NOCOPY varchar2
			,p_proposal_id			IN	NUMBER
			,p_output_path  		IN      VARCHAR2
			,p_narrative_type_code		IN	VARCHAR2
			,p_narrative_submission_code	IN	VARCHAR2
			,p_debug_mode			IN      NUMBER) IS

    CURSOR doc_num IS
    SELECT ece_output_runs_s.nextval
    FROM   dual;

    cursor c_justification is
    select substr(abstract,1,200)
    from   igw_prop_abstracts
    where  proposal_id = p_proposal_id
    and    abstract_type_code = 'C.1'
    and    abstract_type = 'IGW_ABSTRACT_TYPES';

    l_doc_num			NUMBER;
    l_abstract			VARCHAR2(200);
    l_call_status 		BOOLEAN;
    l_proposal_form_number 	VARCHAR2(30);
    l_request_id		BINARY_INTEGER;
    l_msg_count			NUMBER;
    l_msg_data			VARCHAR2(2000);
    l_return_status		VARCHAR2(1);
    l_tmp_out			NUMBER;
    l_procedure_name    	varchar2(200);



  BEGIN
 -- update the narrative_type_code and narrative_submission_code
 -- in igw_proposals_all

    update igw_proposals_all
    set narrative_type_code = p_narrative_type_code,
        narrative_submission_code = p_narrative_submission_code
    where proposal_id = p_proposal_id;


   begin
     select proposal_form_number
     into   l_proposal_form_number
     from   igw_budgets
     where  proposal_id = p_proposal_id
     and    final_version_flag = 'Y';
   exception
     when no_data_found then null;

     when others then
       raise FND_API.G_EXC_ERROR;
   end;

   open c_justification;
   fetch c_justification into l_abstract;
   close c_justification;

    --dbms_output.put_line('l_proposal_form_number'||l_proposal_form_number);
    if l_proposal_form_number is not null then
      igw_report_processing.create_reporting_data(p_proposal_id, l_proposal_form_number, l_return_status,
						l_msg_data, l_msg_count);

      --dbms_output.put_line('l_return_status first'||l_return_status);
      --dbms_output.put_line('l_msg_data first'||l_msg_data);
      if l_return_status <> 'S' then
         l_procedure_name := 'IGW_REPORT_PROCESSING.CREATE_REPORTING_DATA';
         raise FND_API.G_EXC_ERROR;
      end if;

      igw_report_processing.create_base_rate(p_proposal_id, l_proposal_form_number, l_return_status,
						l_msg_data, l_msg_count);
      if l_return_status <> 'S' then
         l_procedure_name := 'IGW_REPORT_PROCESSING.CREATE_BASE_RATE';
         raise FND_API.G_EXC_ERROR;
      end if;

      igw_report_processing.create_budget_justification(p_proposal_id
	  	,l_proposal_form_number, l_return_status, l_msg_data);
      if l_return_status <> 'S' then
         l_procedure_name := 'IGW_REPORT_PROCESSING.CREATE_BUDGET_JUSTIFICATION';
         raise FND_API.G_EXC_ERROR;
      end if;

      if l_abstract is null then
        igw_report_processing.dump_justification(p_proposal_id
	    	,l_proposal_form_number, l_return_status, l_msg_data);
        if l_return_status <> 'S' then
           l_procedure_name := 'IGW_REPORT_PROCESSING.DUMP_JUSTIFICATION';
           raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    end if;


    OPEN  doc_num;
    FETCH doc_num INTO l_doc_num;
    CLOSE doc_num;


    ec_document.send(
	p_api_version_number => 1.0,
	i_Output_Path      => p_output_path,
	i_Output_Filename  => 'PRPO' || to_char(l_doc_num) ,
	i_Transaction_Type => 'PRPO',
	call_status        => l_call_status,
	request_id         => l_request_id,
	x_msg_count        => l_msg_count,
	x_msg_data         => l_msg_data,
	x_return_status    => l_return_status,
	p_parameter1       => p_proposal_id,
	p_parameter2       => null,
	p_parameter3       => null,
	p_parameter4       => null,
	p_parameter5       => null,
	p_parameter6       => null,
	p_parameter7       => null,
	p_parameter8       => null,
	p_parameter9       => null,
	p_parameter10      => null,
	p_parameter11      => null,
	p_parameter12      => null,
	p_parameter13      => null,
	p_parameter14      => null,
	p_parameter15      => null,
	p_parameter16      => null,
	p_parameter17      => null,
	p_parameter18      => null,
	p_parameter19      => null,
	p_parameter20      => null,
	I_DEBUG_MODE	    => p_debug_mode);

    retcode := 0;
    commit;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      retcode := 2;
      if l_return_status = 'U' then
        errbuf := l_msg_data||l_procedure_name;
      else
       errbuf:= errbuf||fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'TRUE');
      end if;

    when others then
      retcode := 2;
      l_msg_data :=  SQLCODE||' '||SQLERRM;
      errbuf := l_msg_data||'IGW_EDI_PROCESSING';
  END submit;


  PROCEDURE update_edi_date  ( x_proposal_id IN  NUMBER) is
  Begin
    update igw_proposals set edi_generated_date = SYSDATE
    where  proposal_id = x_proposal_id;
  End update_edi_date;

END IGW_EDI_PROCESSING;

/
