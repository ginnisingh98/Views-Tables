--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ATTR_LOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ATTR_LOAD_PUB" AS
/* $Header: pvxpldpb.pls 120.6 2005/11/11 15:30 amaram noship $ */
-- Start of Comments
--
--      Funtion name  : Write_Log
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Commonly used to routine to log all the messages
--
--
--
-- End of Comments

--log file declaration
    L_LOG_FILE                              utl_file.file_type;
    TYPE  l_errors_tbl_type  IS TABLE OF varchar2(3000) INDEX BY BINARY_INTEGER;
    l_errors_tbl        l_errors_tbl_type;
    l_error_count               number;


/*********SHOME'S CODE HERE   ************/

/*
   procedure validate_attribute
    ( in_table in PV_PARTNER_ATTR_LOAD_PUB.attr_details_tbl_type ,
      out_table out nocopy PV_PARTNER_ATTR_LOAD_PUB.attr_details_tbl_type ,
      err_table out nocopy error_tbl_type)

    is
      l_attr_value              varchar2(2000);
      l_attr_val_ext            varchar2(4000);
      l_attribute_id            number;

      l_target_date             date := null;
      l_target_number           number := 0;
      l_str_length              number := null;

      l_date_format             varchar2(100);
      l_display_style           varchar2(100);
      l_attribute_type          varchar2(100);
      l_char_width              number;
      l_dec_pts                 number;

      l_no_format               varchar2(30) := null;

      l_attr_value_table        PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;

      l_out_val_table           PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;

      l_v1_row                  pls_integer;
      l_v2_row                  pls_integer;

      l_temp_flag               number := 0;

      l_nth_err_val             binary_integer := 1;
      l_nth_out_val             binary_integer := 1;
      l_nth_out_attr_val        binary_integer := 1;

      l_attr_val_count          binary_integer;

      l_code_ret_flag           boolean;



   begin
       l_v1_row := in_table.first;
       loop
            exit when l_v1_row is null;
            l_attribute_id := in_table(l_v1_row).attribute_id;

            l_attr_value_table := in_table(l_v1_row).attr_values_tbl;

            l_attr_val_count := l_attr_value_table.count;


            select display_style, attribute_type, character_width, decimal_points
            into l_display_style, l_attribute_type, l_char_width, l_dec_pts
            from pv_attributes_vl
            where attribute_id = l_attribute_id;

            if (l_display_style = 'DATE') then
                begin
                    select fnd_profile.value('ICX_DATE_FORMAT_MASK') into l_date_format from dual;
                    l_target_date := to_date(l_attr_value_table(1).attr_value,l_date_format);
                exception
                    when others then
                    l_target_date := null;
                    fnd_message.set_name('PV', 'PV_INVALID_DATE_MSG');
                    fnd_message.set_token('ATTRID', l_attribute_id);
                    err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                    l_nth_err_val := l_nth_err_val + 1;
                end;
                if l_target_date is not null then
                    out_table (l_nth_out_val).attribute_id := l_attribute_id;
                    out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                    l_nth_out_val := l_nth_out_val + 1;
                end if;
            end if;


            if (l_display_style = 'NUMBER') then
                begin
                    l_target_number := to_number(l_attr_value_table(1).attr_value);
                exception
                    when others then
                    l_target_number := null;
                    fnd_message.set_name('PV', 'PV_ONLY_NUM_MSG');
                    fnd_message.set_token('ATTRID', l_attribute_id);
                    err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                    l_nth_err_val := l_nth_err_val + 1;
                end;
                if l_target_number is not null then
                    out_table (l_nth_out_val).attribute_id := l_attribute_id;
                    out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                    l_nth_out_val := l_nth_out_val + 1;
                end if;
            end if;

            if (l_display_style = 'SINGLE' or l_display_style = 'RADIO' ) then
              if (l_attr_val_count > 1) then
                  fnd_message.set_name('PV', 'PV_ONE_VAL_MSG');
                  fnd_message.set_token('ATTRID', l_attribute_id);
                  err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                  l_nth_err_val := l_nth_err_val + 1;
              else
                  l_code_ret_flag := validate_codes(l_attribute_id,l_attr_value_table(1).attr_value);
                  if l_code_ret_flag = true then
                    out_table (l_nth_out_val).attribute_id := l_attribute_id;
                    out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                    l_nth_out_val := l_nth_out_val + 1;
                  else
                    fnd_message.set_name('PV', 'PV_SINGLE_INVALID_VAL_MSG');
                    fnd_message.set_token('ATTRID', l_attribute_id);
                    err_table (l_nth_err_val).error_desc :=  substrb(fnd_message.get, 1, 1000);
                    l_nth_err_val := l_nth_err_val + 1;
                  end if;
              end if;
            end if;


            if (l_display_style = 'CHECK' or l_display_style = 'MULTI' ) then
                l_v2_row := l_attr_value_table.first;
                loop
                    exit when l_v2_row is null;
                    l_attr_value := l_attr_value_table(l_v2_row).attr_value;
                    l_code_ret_flag := validate_codes(l_attribute_id,l_attr_value);
                    if l_code_ret_flag = true then
                        l_temp_flag := 1;
                    else
                        l_temp_flag := 0;
                        exit;
                    end if;
                    l_v2_row := l_attr_value_table.next(l_v2_row);
                end loop;
                if l_temp_flag = 1 then
                   out_table (l_nth_out_val).attribute_id := l_attribute_id;
                   out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                   l_nth_out_val := l_nth_out_val + 1;
                else
                   fnd_message.set_name('PV', 'PV_MULTI_INVALID_VAL_MSG');
                   fnd_message.set_token('ATTRID', l_attribute_id);
                   err_table (l_nth_err_val).error_desc :=  substrb(fnd_message.get, 1, 1000);
                   l_nth_err_val := l_nth_err_val + 1;
                end if;
             end if;

             if l_attribute_type = 'DROPDOWN' and l_display_style = 'PERCENTAGE' then
                l_v2_row := l_attr_value_table.first;
                loop
                    exit when l_v2_row is null;
                    l_attr_value := l_attr_value_table(l_v2_row).attr_value;
                    l_attr_val_ext := l_attr_value_table(l_v2_row).attr_value_extn;

                    if l_attr_value is null then
                        l_temp_flag := 0;
                        exit;
                    else
                        l_code_ret_flag := validate_codes(l_attribute_id,l_attr_value);

                        if l_code_ret_flag = false then
                            l_temp_flag := 0;
                            exit;
                        else
                            l_temp_flag := 1;
                            if l_attr_val_ext is not null then
                               begin
                                    l_target_number := l_target_number + to_number(l_attr_val_ext);
                                    l_out_val_table(l_nth_out_attr_val).attr_value := l_attr_value;
                                    l_out_val_table(l_nth_out_attr_val).attr_value_extn := l_attr_val_ext;
                                    l_nth_out_attr_val := l_nth_out_attr_val + 1;
                                exception
                                when others then
                                    fnd_message.set_name('PV', 'PV_ONLY_NUM_MSG');
                                    fnd_message.set_token('ATTRID', l_attribute_id);
                                    err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                                    l_nth_err_val := l_nth_err_val + 1;
                                end;
                            end if;
                        end if;
                    end if;
                    l_v2_row := l_attr_value_table.next(l_v2_row);
                end loop;
                if l_temp_flag = 1 then
                    if l_target_number > 100 then
                        fnd_message.set_name('PV', 'PV_VAL_EXCDS_100_MSG');
                        fnd_message.set_token('ATTRID', l_attribute_id);
                        err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                        l_nth_err_val := l_nth_err_val + 1;
                    else
                        if l_out_val_table.count > 0 then
                            out_table (l_nth_out_val).attribute_id := l_attribute_id;
                            out_table (l_nth_out_val).attr_values_tbl := l_out_val_table;
                            l_nth_out_val := l_nth_out_val + 1;
                        end if;
                    end if;
                else
                    fnd_message.set_name('PV', 'PV_MULTI_INVALID_VAL_MSG');
                    fnd_message.set_token('ATTRID', l_attribute_id);
                    err_table (l_nth_err_val).error_desc :=  substrb(fnd_message.get, 1, 1000);
                    l_nth_err_val := l_nth_err_val + 1;
                end if;
             end if;

             if l_display_style = 'STRING' then
                l_str_length := length(l_attr_value_table(1).attr_value);
                if l_char_width is not null and l_str_length > l_char_width then
                    fnd_message.set_name('PV', 'PV_LONG_STR_MSG');
                    fnd_message.set_token('ATTRID', l_attribute_id);
                    err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                    l_nth_err_val := l_nth_err_val + 1;
                else
                    out_table (l_nth_out_val).attribute_id := l_attribute_id;
                    out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                    l_nth_out_val := l_nth_out_val + 1;
                end if;
             end if;

             if l_display_style = 'CURRENCY' then
                 if l_dec_pts is not null then
                    for i in 1..l_dec_pts loop
                        l_no_format := l_no_format ||'9';
                    end loop;
                    l_no_format := trim(l_no_format||'.99');

                    begin
                        l_target_number := to_number(l_attr_value_table(1).attr_value,l_no_format);
                    exception
                    when others then
                        l_target_number := null;
                        fnd_message.set_name('PV', 'PV_ONLY_NUM_MSG');
                        fnd_message.set_token('ATTRID', l_attribute_id);
                        err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                        l_nth_err_val := l_nth_err_val + 1;
                    end;
                    if l_target_number is not null then
                        out_table (l_nth_out_val).attribute_id := l_attribute_id;
                        out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                        l_nth_out_val := l_nth_out_val + 1;
                    end if;
                else
                    begin
                        l_target_number := to_number(l_attr_value_table(1).attr_value);
                    exception
                    when others then
                        l_target_number := null;
                        fnd_message.set_name('PV', 'PV_ONLY_NUM_MSG');
                        fnd_message.set_token('ATTRID', l_attribute_id);
                        err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
                        l_nth_err_val := l_nth_err_val + 1;
                    end;
                    if l_target_number is not null then
                        out_table (l_nth_out_val).attribute_id := l_attribute_id;
                        out_table (l_nth_out_val).attr_values_tbl := l_attr_value_table;
                        l_nth_out_val := l_nth_out_val + 1;
                    end if;
                 end if;
             end if;

            l_v1_row := in_table.next(l_v1_row);
       end loop;

    exception
    when others then
         fnd_message.set_name('PV', 'PV_VALIDATE_GEN_ERROR');
         err_table (l_nth_err_val).error_desc := substrb(fnd_message.get, 1, 1000);
         l_nth_err_val := l_nth_err_val + 1;
    end;


    function validate_codes
    (
        in_attribute_id in number,
        in_attr_value in varchar2
    )
    return boolean
    is

    l_attr_code               varchar2(100);
    l_ret_value               boolean := false;

    cursor get_attribute_codes(attr_id number) is
    select attr_code
    from pv_attribute_codes_vl
    where attribute_id = attr_id;

    begin
       if in_attr_value is not null then
          open get_attribute_codes(in_attribute_id);
          loop
              fetch get_attribute_codes into l_attr_code;
              if (get_attribute_codes%rowcount = 0) then
                exit;
              else
                if (get_attribute_codes%rowcount <> 0) then
                 if (get_attribute_codes%notfound) then
                   exit;
                 else
                   if (in_attr_value = l_attr_code) then
                     l_ret_value := true ;
                     exit;
                   end if;
                 end if;
                end if;
             end if;
          end loop;
          close get_attribute_codes;
       else
        if in_attr_value is null then
            l_ret_value := true ;
        end if;
       end if;
      return l_ret_value;
      exception
      when others then
       return false;
   end;

*/
/*********SHOME'S CODE ENDS HERE ***************************/

/*
PROCEDURE Write_Log(p_log_file utl_file.file_type, p_msg  varchar2) IS
BEGIN

    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);

  --  utl_file.put_line(p_log_file, p_msg);
      --dbms_output.put_line(' ');


END Write_Log;
*/
-- Start of Comments
--
--      Funtion name  : Write_Log
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Commonly used to routine to log all the messages
--
--
--
-- End of Comments

PROCEDURE Write_Error IS

BEGIN
    --dbms_output.put_line('Error Count: ' || l_errors_tbl.count);
    if l_errors_tbl.count > 0 then
        for i in 1..l_errors_tbl.count
        loop
            utl_file.put_line(L_LOG_FILE, rpad(' ',100) || l_errors_tbl(i));
            --dbms_output.put_line('Error: ' || l_errors_tbl(i));
        end loop;
        l_errors_tbl.delete;
    end if;

END Write_Error;

-- Start of Comments
--
--      Funtion name  : Validate_Party
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Validate all the information passed related to party.
--
--
--
-- End of Comments
Procedure Validate_Party(
                            p_party_id              IN NUMBER,
                            p_orig_sys              IN varchar2,
                            p_orig_sys_ref          IN varchar2,
                            p_partner_id            IN NUMBER,
                            p_partner_name          IN varchar2,
                            p_type                  IN varchar2,
                            x_party_id              OUT NOCOPY NUMBER,
                            x_exit_partner          OUT NOCOPY varchar2
)
IS

    CURSOR l_valid_OSR(cv_orig_system IN VARCHAR2, cv_orig_system_ref IN VARCHAR2) IS
    select
            'Y',
			hz_parties.party_id

			from
				hz_orig_sys_references,
				hz_parties

			where
			    hz_orig_sys_references.owner_table_id = hz_parties.party_id and
			    hz_parties.party_type = 'ORGANIZATION' AND
				hz_orig_sys_references.orig_system = cv_orig_system and
				hz_orig_sys_references.orig_system_reference = cv_orig_system_ref and
				hz_orig_sys_references.owner_table_name = 'HZ_PARTIES' AND
                hz_parties.status = 'A';


    cursor l_valid_POSR(cv_party_id IN NUMBER, cv_osr in varchar2) IS
        select
                'Y'
        FROM
            hz_parties
        where
            party_id = cv_party_id and
            orig_system_reference = cv_osr and
            party_type = 'ORGANIZATION' and
            status = 'A';


    cursor l_valid_PartyId(cv_party_id IN NUMBER) IS
        select
                'Y'
        FROM
            hz_parties
        where
            party_id = cv_party_id and
            party_type = 'ORGANIZATION' and
            status = 'A';


    cursor l_valid_Party(cv_party_id IN NUMBER) IS
        select
                'Y'
        FROM
            hz_parties
        where
            party_id = cv_party_id and
            party_type = 'ORGANIZATION' and
            status = 'A';

    cursor l_valid_POSOSR(cv_party_id IN NUMBER, cv_os IN VARCHAR, cv_osr IN VARCHAR) IS
        select
                'Y'
			from
				hz_orig_sys_references,
				hz_parties

			where
    			hz_parties.party_id = cv_party_id and
			    hz_orig_sys_references.owner_table_id = hz_parties.party_id and
			    hz_parties.party_type = 'ORGANIZATION' AND
				hz_orig_sys_references.orig_system = cv_os and
				hz_orig_sys_references.orig_system_reference = cv_osr and
				hz_orig_sys_references.owner_table_name = 'HZ_PARTIES' AND
                hz_parties.status = 'A';

    cursor l_valid_partner_id(cv_partner_id IN NUMBER, cv_party_id IN Number) is
        select
            'Y'
        from
            pv_partner_profiles
        where
            partner_id = cv_partner_id and
            partner_party_id = cv_party_id;
--            and status = 'A';


    cursor l_valid_PartnerParty(cv_partner_id number) IS
    select
            'Y',
    		hz_parties.party_id

    		from
    		     pv_partner_profiles,
    		     hz_parties

    		where
    		     partner_id = cv_partner_id and
--    		     pv_partner_profiles.status = 'A' and
    		     party_id = partner_party_id and
    		     hz_parties.status = 'A' and
    		     hz_parties.party_type = 'ORGANIZATION';


    l_valid         varchar2(1);
    l_party_id      NUMBER;

BEGIN

    --dbms_output.put_line('Processing party validation ');
    x_exit_partner := 'FALSE';
    l_party_id := p_party_id;
    l_valid := 'N';
    if (p_party_id is null AND p_orig_sys is null and p_orig_sys_ref is null and p_partner_id is null) then
        --dbms_output.put_line('not sure how i got here ');
            fnd_message.set_name('PV', 'PV_IMP_PARTY_IDENT_REQ');
            fnd_message.set_token( 'TYPE', p_type);
            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
            l_error_count := l_error_count +1;
        	x_exit_partner := 'TRUE';
            --dbms_output.put_line('Party information is required. Please provide this information to process further');
    elsif (p_party_id is not null and p_orig_sys_ref is not null) and (p_orig_sys is null) then
            l_valid := 'N';
            Open l_valid_POSR(p_party_id, p_orig_sys_ref);
            fetch l_valid_POSR into l_valid;
            close l_valid_POSR;
            if not l_valid = 'Y' then
                fnd_message.set_name('PV', 'PV_IMP_PARTY_REF');
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
                --dbms_output.put_line('Party Id passed does not match the reference passed. Please check your data ');
                x_exit_partner := 'TRUE';
            end if;
    elsif (p_party_id is null and p_orig_sys_ref is null and p_orig_sys is not null) then

            l_valid := 'N';
            fnd_message.set_name('PV', 'PV_IMP_PARTY_IDENT_REQ');
            fnd_message.set_token( 'TYPE', p_type);
            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
            l_error_count := l_error_count +1;
           	x_exit_partner := 'TRUE';
/*            dbms_output.put_line('Party identification information is required. Please provide either
                                            1.	Party Id  (OR)
                                            2.	Original System and Original System Reference');
*/
    elsif (p_party_id is null and (p_orig_sys_ref is not null and p_orig_sys is not null)) then
            l_valid := 'N';
            Open l_valid_OSR(p_orig_sys, p_orig_sys_ref);
            fetch l_valid_OSR into l_valid,l_party_id;
            close l_valid_OSR;
            if not l_valid = 'Y' then
                fnd_message.set_name('PV', 'PV_IMP_CUST_NOT_FOUND');
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
--                dbms_output.put_line('Party not found as a Customer. Please ensure that it is present in the TCA table');
                x_exit_partner := 'TRUE';
            end if;
   elsif (p_party_id is not null AND p_orig_sys is not null and p_orig_sys_ref is not null) then
            l_valid := 'N';
            Open l_valid_POSOSR(p_party_id,p_orig_sys,p_orig_sys_ref);
            fetch l_valid_POSOSR into l_valid;
            close l_valid_POSOSR;
            if not l_valid = 'Y' then
                fnd_message.set_name('PV', 'PV_IMP_PARTY_OSR');
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
--                dbms_output.put_line('Party Id and party references does not match. Please check your data ');
                x_exit_partner := 'TRUE';
            end if;
   elsif (p_party_id is not null) then
            l_valid := 'N';
            Open l_valid_PartyId(p_party_id);
            fetch l_valid_PartyId into l_valid;
            close l_valid_PartyId;
            if not l_valid = 'Y' then
                fnd_message.set_name('PV', 'PV_IMP_CUST_NOT_FOUND');
                fnd_message.set_token( 'PARTYNAME', p_partner_name);
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
                --dbms_output.put_line('Party not found as a Customer. Please ensure that it is present in the TCA table');
                x_exit_partner := 'TRUE';
            end if;
   elsif (p_partner_id is not null) then
            --dbms_output.put_line('getting into the partner id check ');
            --dbms_output.put_line('partner id being checked ' || p_partner_id);
            l_valid := 'N';
            Open l_valid_PartnerParty(p_partner_id);
            fetch l_valid_PartnerParty into l_valid,l_party_id;
            close l_valid_PartnerParty;
            --dbms_output.put_line('valid partner ' || l_valid);
            if not l_valid = 'Y' then
            fnd_message.set_name('PV', 'PV_IMP_PARTY_IDENT_REQ');
            fnd_message.set_token( 'TYPE', p_type);
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
                /*dbms_output.put_line('Party identification information is required. Please provide either
                                            1.	Party Id  (OR)
                                            2.	Original System and Original System Reference');
                */
                x_exit_partner := 'TRUE';
            end if;
            --dbms_output.put_line('found the party ' || l_party_id);

    else
        --dbms_output.put_line('not sure how i got here ');
            fnd_message.set_name('PV', 'PV_IMP_PARTY_IDENT_REQ');
            fnd_message.set_token( 'TYPE', p_type);
            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
            l_error_count := l_error_count +1;
        	x_exit_partner := 'TRUE';
            --dbms_output.put_line('Party information is required. Please provide this information to process further');
   end if;

   if (p_partner_id is not null)  and (l_party_id is not null) then
        l_valid := 'N';

        open l_valid_partner_id(p_partner_id, l_party_id);
        fetch l_valid_partner_id into l_valid;
        close l_valid_partner_id;
        if not l_valid = 'Y' then
                fnd_message.set_name('PV', 'PV_IMP_INVALID_PTNR');
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
                --dbms_output.put_line('invalid partner passed');
                x_exit_partner := 'TRUE';
        end if;

   end if;
   x_party_id := l_party_id;


END Validate_Party;


-- Start of Comments
--
--      Funtion name  : Validate_And_Create_Partner
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:  Validate all the required fields and business validations for the
--              attributes passed. If the validations are successful create the
--              partner and its attributes
--
-- End of Comments
Procedure Validate_And_Create_Partner(
    p_party_id              IN NUMBER,
    p_partner_details_rec   IN partner_details_rec_type,
    x_partner_id            OUT NOCOPY NUMBER,
    x_exit_partner      OUT NOCOPY varchar2
)
IS

    CURSOR l_get_party_id(cv_orig_system IN VARCHAR2, cv_orig_system_ref IN VARCHAR2) IS
         SELECT
    				hz_parties.party_id

    				from
    					hz_orig_sys_references,
    					hz_parties

    				where
    				    hz_orig_sys_references.owner_table_id = hz_parties.party_id and
    				    hz_parties.party_type = 'ORGANIZATION' AND
    					hz_orig_sys_references.orig_system = cv_orig_system and
    					hz_orig_sys_references.orig_system_reference = cv_orig_system_ref and
    					hz_orig_sys_references.owner_table_name = 'HZ_PARTIES' AND
                        hz_parties.status = 'A';

    CURSOR l_get_partner_id(cv_party_id IN NUMBER) IS
        SELECT
    			partner_id
		FROM
			    pv_partner_profiles

		WHERE
			    partner_party_id = cv_party_id;
--                 and	status = 'A';


    CURSOR l_get_glbl_member_type(cv_partner_id IN NUMBER) is
        SELECT
                attr_value
        from
                pv_enty_attr_values
        where
                attribute_id = 6 and
                latest_flag = 'Y' and
                entity_id = cv_partner_id;


    CURSOR l_check_acct_exists(cv_party_id IN NUMBER) is
        SELECT
                'Y'
        from
                hz_cust_accounts
        where
                party_id = cv_party_id and
    			status = 'A';


    CURSOR C_party_info (l_party_id NUMBER) IS
        SELECT
                party_type, party_name
        FROM
                hz_parties
        WHERE
                party_id = l_party_id;


    CURSOR C_acct_number IS
    --SELECT pv_account_number_s.nextval FROM  dual;
        SELECT 1000 from dual;


    l_bound                 Number;
    u_bound                 Number;
    l_has_partner_type      varchar2(1);
    l_has_member_type       varchar2(1);
    l_is_subsidiary         varchar2(1);
    l_attribute_details_tbl attr_details_tbl_type;
    l_attr_values_tbl       PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type; --attr_values_tbl_type;
    l_party_id              number;
    l_partner_id            number;
    l_partner_name          varchar2(360);
    l_gbl_orig_system       varchar2(30);
    l_gbl_orig_system_ref   varchar2(255);
    l_gbl_party_id          number;
    l_gbl_partner_id        number;
    l_partner_types_tbl     PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
    l_partner_member_type   varchar2(500);
    l_member_type           varchar2(500);
    l_default_resp_id       NUMBER;
    l_resp_map_rule_id      NUMBER;
    l_group_id              NUMBER;
    l_gbl_partner_name      varchar(360);
    l_out_gbl_party_id      NUMBER;


    l_account_rec           HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    l_organization_rec      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_cust_profile_rec      HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_cust_account_id       NUMBER;
    l_account_number        NUMBER;
    l_party_number          NUMBER;
    l_profile_id            NUMBER;
    l_account_exists        varchar2(1);
    l_gen_cust_num          VARCHAR2(1);

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR(2000);



BEGIN
    --dbms_output.put_line('let me check');

    l_has_partner_type  := 'N';
    l_has_member_type   := 'N';
    l_is_subsidiary     := 'N';
    l_party_id          := p_party_id;
    x_exit_partner      := 'FALSE';

    l_attribute_details_tbl := p_partner_details_rec.attribute_details_tbl;



    l_bound                 := l_attribute_details_tbl.first;
    u_bound                 := l_attribute_details_tbl.last;


    for i in l_bound..u_bound
    loop
        if l_attribute_details_tbl(i).attribute_id = 3 then
                l_has_partner_type := 'Y';
                l_attr_values_tbl := l_attribute_details_tbl(i).attr_values_tbl;
                for j in l_attr_values_tbl.first..l_attr_values_tbl.last
                loop
                   l_partner_types_tbl(1).attr_value := l_attr_values_tbl(j).attr_value;
                   l_partner_types_tbl(1).attr_value_extn := 'Y';
                end loop;
        end if;
        if l_attribute_details_tbl(i).attribute_id = 6 then
                l_has_member_type := 'Y';
                l_attr_values_tbl := l_attribute_details_tbl(i).attr_values_tbl;
            for j in l_attr_values_tbl.first..l_attr_values_tbl.last
            loop
                    l_partner_member_type := l_attr_values_tbl(j).attr_value;
                    if l_attr_values_tbl(j).attr_value = 'SUBSIDIARY' then
                        l_is_subsidiary := 'Y';
                    end if;
            end loop;
        end if;

    end loop;
--dbms_output.put_line('exit partner status ' || x_exit_partner);
    if NOT l_has_partner_type = 'Y' then
            fnd_message.set_name('PV', 'PV_IMP_REQ_DATA');
			fnd_message.set_token( 'PARAM', 'Partner Type');
            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
            l_error_count := l_error_count +1;
			--dbms_output.put_line('Partner Type' || 'is missing ');
            x_exit_partner := 'TRUE';
    end if;

    if NOT l_has_member_type = 'Y' then
            fnd_message.set_name('PV', 'PV_IMP_REQ_DATA');
			fnd_message.set_token( 'PARAM', 'Member Type');
            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
            l_error_count := l_error_count +1;
			--dbms_output.put_line('Member Type' || 'is missing ');
            x_exit_partner := 'TRUE';
    end if;

    if l_is_subsidiary = 'Y' then

            l_gbl_orig_system := p_partner_details_rec.gbl_orig_system;
            l_gbl_orig_system_ref := p_partner_details_rec.gbl_orig_system_ref;
            l_gbl_party_id := p_partner_details_rec.gbl_party_id;
            l_partner_name  := p_partner_details_rec.partner_name;
            l_gbl_partner_id := p_partner_details_rec.gbl_partner_id;

            Validate_Party(
                            p_party_id      => l_gbl_party_id,
                            p_orig_sys      => l_gbl_orig_system,
                            p_orig_sys_ref  => l_gbl_orig_system_ref,
                            p_partner_id    => l_gbl_partner_id,
                            p_partner_name  => l_partner_name,
                            p_type          => 'Global ',
                            x_party_id      => l_out_gbl_party_id,
                            x_exit_partner  => x_exit_partner
                        );
                        l_gbl_party_id := l_out_gbl_party_id;

           if x_exit_partner <> 'TRUE' then
                OPEN l_get_partner_id(l_gbl_party_id);
                FETCH l_get_partner_id into l_gbl_partner_id;
                close l_get_partner_id;
                if l_gbl_partner_id is null then
                    fnd_message.set_name('PV', 'PV_IMP_GLBL_PARTY');
                    l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                    l_error_count := l_error_count +1;
                	--dbms_output.put_line('Global partner does not exist');
                	x_exit_partner := 'TRUE';
                end if;
            end if;

            if x_exit_partner <> 'TRUE' then
                OPEN l_get_glbl_member_type(l_gbl_partner_id);
                FETCH l_get_glbl_member_type into l_member_type;
                CLOSE l_get_glbl_member_type;
                if l_member_type <> 'GLOBAL' then
                    fnd_message.set_name('PV', 'PV_IMP_NOT_GLBL_PTNR');
                    l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                    l_error_count := l_error_count +1;
                	--dbms_output.put_line('Global partner exists but not of type Global');
                	x_exit_partner := 'TRUE';
                end if;
            end if;


    end if;



    --dbms_output.put_line('Valid Partner?? ' || x_exit_partner );
    if x_exit_partner <> 'TRUE' then

        --dbms_output.put_line('Account Creation' );
        --dbms_output.put_line('Party Id: ' || l_party_id);
        l_account_exists := 'N';
        open l_check_acct_exists(l_party_id);
        fetch l_check_acct_exists into l_account_exists;
        close l_check_acct_exists;

        --dbms_output.put_line('account exists? ' || l_account_exists);
        if l_account_exists <> 'Y' then


                --dbms_output.put_line('trying to gen num ');
             -- if needed generate account_number.
--                SELECT generate_customer_number INTO l_gen_cust_num FROM ar_system_parameters;

               -- typically should be set to 'Y' if no we will try to create a new one.
               -- however, this could error out
               -- Is this needed????
                --dbms_output.put_line('Generate cust num ' || l_gen_cust_num);
                  IF l_gen_cust_num = 'N' THEN

                           OPEN C_acct_number;
                           FETCH C_acct_number into  l_account_rec.account_number;
                           CLOSE C_acct_number;

                           l_account_rec.account_number := 'PV'|| l_account_rec.account_number;

                  END IF;
                  --dbms_output.put_line('account num ' || l_account_rec.account_number);

                l_account_rec.Created_by_Module := 'PV';
                l_account_rec.application_id := 691;
                l_organization_rec.Created_by_Module := 'PV';
                l_cust_profile_rec.Created_by_Module := 'PV';
                l_cust_profile_rec.application_id := 691;
                l_organization_rec.party_rec.party_Id := l_party_id;
                l_organization_rec.application_id := 691;
                l_account_rec.account_name := 'System Generated Account';


                 HZ_CUST_ACCOUNT_V2PUB.create_cust_account
                         (
                            p_init_msg_list            => FND_API.G_FALSE,
                            p_cust_account_rec         => l_account_rec,
                            p_organization_rec         => l_organization_rec,
                            p_customer_profile_rec     => l_cust_profile_rec,
                            p_create_profile_amt       => FND_API.G_TRUE,
                            x_cust_account_id          => l_cust_account_id,
                            x_account_number           => l_account_number,
                            x_party_id                 => l_party_id,
                            x_party_number             => l_party_number,
                            x_profile_id               => l_profile_id,
                            x_return_status            => l_return_status,
                            x_msg_count                => l_msg_count,
                            x_msg_data                 => l_msg_data
                         );


                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.put_line('Error Occured: ');
                        --dbms_output.put_line('Error: ' || l_msg_data);
                        FOR l_msg_index IN 1..l_msg_count LOOP
                            apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
                            l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                            l_error_count := l_error_count +1;
                            --dbms_output.put_line('Error Details: ');
                            --dbms_output.put_line(substr(apps.fnd_message.get,1,254));

                        END LOOP;
                        x_exit_partner := 'TRUE';
                    END IF;
                --dbms_output.put_line('RETURN STATUS ' || l_return_status);
                --dbms_output.put_line('MESSAGE ' || l_msg_data);
        end if;
        l_party_id := p_party_id;

        if x_exit_partner <> 'TRUE' then
            --dbms_output.put_line('cALLING CREATE RELATIONSHIP ');
            --dbms_output.put_line('party id: ' || l_party_id);
            --dbms_output.put_line('member type: ' || l_partner_member_type);


            begin
          	PV_PARTNER_UTIL_PVT.Create_Relationship(
        		p_api_version_number => 1.0
        		,p_init_msg_list     => FND_API.G_FALSE
        		,p_commit            => FND_API.G_FALSE
        		,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        		,x_return_status     => l_return_status
        		,x_msg_data          => l_msg_data
        		,x_msg_count         => l_msg_count
        		,p_party_id	      	 => l_party_id
        		,p_partner_types_tbl => l_partner_types_tbl
        		,p_vad_partner_id    => Null
        		,p_member_type       => l_partner_member_type
        		,p_global_partner_id => l_gbl_partner_id
        		,x_partner_id        => l_partner_id
        		,x_default_resp_id   => l_default_resp_id
        		,x_resp_map_rule_id  => l_resp_map_rule_id
        		,x_group_id          => l_group_id
        	);

             EXCEPTION

             WHEN FND_API.g_exc_error THEN
                  l_return_status := FND_API.g_ret_sts_error;
                  FND_MSG_PUB.count_and_get (
                       p_encoded => FND_API.g_false
                      ,p_count   => l_msg_count
                      ,p_data    => l_msg_data
                      );
                    --dbms_output.put_line('Message : ' || l_msg_data );
            WHEN FND_API.g_exc_unexpected_error THEN
              l_return_status := FND_API.g_ret_sts_unexp_error ;
              FND_MSG_PUB.count_and_get (
                   p_encoded => FND_API.g_false
                  ,p_count   => l_msg_count
                  ,p_data    => l_msg_data
                  );
                --dbms_output.put_line('Message : ' || l_msg_data );

             WHEN OTHERS THEN
                    --dbms_output.put_line('Exception ' || sqlerrm);
                  l_return_status := FND_API.g_ret_sts_unexp_error ;
                  FND_MSG_PUB.count_and_get (
                       p_encoded => FND_API.g_false
                      ,p_count   => l_msg_count
                      ,p_data    => l_msg_data
                      );

              END;
                --dbms_output.put_line('Return status for Create_Rela : ' ||  l_return_status);
                --dbms_output.put_line('Message: ' || l_msg_data);

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.put_line('Error Occured: ');
                --dbms_output.put_line('Error: ' || l_msg_data);
                FOR l_msg_index IN 1..l_msg_count LOOP
                    apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
                    l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                    l_error_count := l_error_count +1;
                    --dbms_output.put_line('Error Details: ');
                    --dbms_output.put_line(substr(apps.fnd_message.get,1,254));
                END LOOP;
                x_exit_partner := 'TRUE';
    --            p_partner_details_rec.processed := 'N';
            END IF;
            --dbms_output.put_line('Partner ID: ' || l_partner_id);
            --dbms_output.put_line('Exit Partner :  ' || x_exit_partner);
            x_partner_id := l_partner_id;
        end if;
    end if;
    --dbms_output.put_line('SUCCESSFULLY ENDED PARTNER CREATION ');
END Validate_And_Create_Partner;

-- Start of Comments
--
--      Funtion name  : Validate_Update_Attributes
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Validate all the passed data for an existing partner attributes
--
--
--
-- End of Comments
Procedure Validate_Update_Attributes(
    p_partner_details_rec   IN partner_details_rec_type,
    p_partner_id            IN NUMBER,
    x_exit_partner      OUT NOCOPY varchar2
)
IS


   CURSOR l_get_partner_type(cv_partner_id IN NUMBER) IS
        select
                attr_value
        from
                pv_enty_attr_values
        where
                entity_id    = cv_partner_id and
                attribute_id = 3 and
                latest_flag = 'Y';



    l_bound             Number;
    u_bound             Number;
    l_has_partner_type  varchar2(1);
    l_has_member_type   varchar2(1);
    l_new_partner_type     varchar2(500);
    l_attribute_details_tbl attr_details_tbl_type;
    l_attr_values_tbl   PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type; --attr_values_tbl_type;
    l_partner_id            number;
    l_current_partner_type            varchar2(500);



BEGIN
    --dbms_output.put_line('let me check');
    l_attribute_details_tbl := p_partner_details_rec.attribute_details_tbl;
    l_bound := l_attribute_details_tbl.first;
    u_bound := l_attribute_details_tbl.last;
    x_exit_partner := 'FALSE';


    for i in l_bound..u_bound
    loop
        if l_attribute_details_tbl(i).attribute_id = 6 then
                l_has_member_type := 'Y';
        end if;
        if l_attribute_details_tbl(i).attribute_id = 3 then
                l_has_partner_type := 'Y';
                l_attr_values_tbl := l_attribute_details_tbl(i).attr_values_tbl;
            for j in l_attr_values_tbl.first..l_attr_values_tbl.last
            loop
                    l_new_partner_type := l_attr_values_tbl(j).attr_value;
            end loop;
        end if;
    end loop;

    if l_has_member_type = 'Y' then
        fnd_message.set_name('PV', 'PV_IMP_UPD_MEM_TYP');
        l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
        l_error_count := l_error_count +1;
        x_exit_partner := 'TRUE';
        --dbms_output.put_line('updating member type is not allowed while importing');
    end if;

    if l_has_partner_type = 'Y' then

        OPEN l_get_partner_type(p_partner_id);
        FETCH l_get_partner_type into l_current_partner_type;
        close l_get_partner_type;
        --dbms_output.put_line('Current partner type ' || l_current_partner_type);
        --dbms_output.put_line('new partner type ' || l_new_partner_type);
        if l_current_partner_type = 'VAD' or l_new_partner_type = 'VAD' then
            if not (l_current_partner_type = 'VAD' AND l_new_partner_type = 'VAD') then
                fnd_message.set_name('PV', 'PV_IMP_UPD_PTNR_TYP');
                fnd_message.set_token( 'FROM', l_current_partner_type );
                fnd_message.set_token( 'TO', l_new_partner_type );
                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                l_error_count := l_error_count +1;
                x_exit_partner := 'TRUE';
                --dbms_output.put_line('Cannot update partner type to VAD');
            end if;
        end if;

    end if;

END Validate_Update_Attributes;

-- Start of Comments
--
--      Funtion name  : Upsert_Attr_Values
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Upsert all the attributes for the partner, also take care of
--              creating the channel team and update the partner profile based
--              on business rules.
--
-- End of Comments

PROCEDURE Complete_Prtnr_Prfls_Rec(
   p_prtnr_prfls_rec IN  PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type
  ,x_complete_rec    OUT NOCOPY PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type
  )
IS

   CURSOR c_prtnr_prfls IS
   SELECT
			partner_profile_id
				,last_update_date
				,last_updated_by
				,creation_date
				,created_by
				,last_update_login
				,object_version_number
				,partner_id
				,target_revenue_amt
				,actual_revenue_amt
				,target_revenue_pct
				,actual_revenue_pct
				,orig_system_reference
				,orig_system_type
				,capacity_size
				,capacity_amount
				,auto_match_allowed_flag
				,purchase_method
				,cm_id
				,ph_support_rep
				--,security_group_id
				,lead_sharing_status
				,lead_share_appr_flag
				,partner_relationship_id
				,partner_level
				,preferred_vad_id
				,partner_group_id
				,partner_resource_id
				,partner_group_number
				,partner_resource_number
				,sales_partner_flag
				,indirectly_managed_flag
				,channel_marketing_manager
				,related_partner_id
				,max_users
				,partner_party_id
				,status

	FROM  PV_PARTNER_PROFILES
    WHERE partner_profile_id = p_prtnr_prfls_rec.partner_profile_id;

   l_prtnr_prfls_rec   PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type;

BEGIN

   x_complete_rec := p_prtnr_prfls_rec;

   OPEN c_prtnr_prfls;
   FETCH c_prtnr_prfls INTO l_prtnr_prfls_rec;
   IF c_prtnr_prfls%NOTFOUND THEN
      CLOSE c_prtnr_prfls;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_RECORD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_prtnr_prfls;

IF p_prtnr_prfls_rec.partner_id  is null THEN
   x_complete_rec.partner_id        := l_prtnr_prfls_rec.partner_id;
END IF;

IF p_prtnr_prfls_rec.target_revenue_amt is null THEN
   x_complete_rec.target_revenue_amt        := l_prtnr_prfls_rec.target_revenue_amt;
END IF;

IF p_prtnr_prfls_rec.actual_revenue_amt is null THEN
   x_complete_rec.actual_revenue_amt        := l_prtnr_prfls_rec.actual_revenue_amt;
END IF;

IF p_prtnr_prfls_rec.target_revenue_pct is null THEN
   x_complete_rec.target_revenue_pct        := l_prtnr_prfls_rec.target_revenue_pct;
END IF;

IF p_prtnr_prfls_rec.actual_revenue_pct is null THEN
   x_complete_rec.actual_revenue_pct        := l_prtnr_prfls_rec.actual_revenue_pct;
END IF;

IF p_prtnr_prfls_rec.orig_system_reference is null  THEN
   x_complete_rec.orig_system_reference        := l_prtnr_prfls_rec.orig_system_reference;
END IF;

IF p_prtnr_prfls_rec.orig_system_type is null THEN
   x_complete_rec.orig_system_type        := l_prtnr_prfls_rec.orig_system_type;
END IF;

IF p_prtnr_prfls_rec.capacity_size  is null THEN
   x_complete_rec.capacity_size        := l_prtnr_prfls_rec.capacity_size;
END IF;

IF p_prtnr_prfls_rec.capacity_amount is null  THEN
   x_complete_rec.capacity_amount        := l_prtnr_prfls_rec.capacity_amount;
END IF;

IF p_prtnr_prfls_rec.auto_match_allowed_flag  is null  THEN
   x_complete_rec.auto_match_allowed_flag        := l_prtnr_prfls_rec.auto_match_allowed_flag;
END IF;

IF p_prtnr_prfls_rec.purchase_method is null  THEN
   x_complete_rec.purchase_method        := l_prtnr_prfls_rec.purchase_method;
END IF;

IF p_prtnr_prfls_rec.cm_id is null  THEN
   x_complete_rec.cm_id        := l_prtnr_prfls_rec.cm_id;
END IF;

IF p_prtnr_prfls_rec.ph_support_rep  is null  THEN
   x_complete_rec.ph_support_rep        := l_prtnr_prfls_rec.ph_support_rep;
END IF;

IF p_prtnr_prfls_rec.object_version_number is null THEN
   x_complete_rec.object_version_number        := l_prtnr_prfls_rec.object_version_number;
END IF;

IF p_prtnr_prfls_rec.lead_sharing_status  is null  THEN
   x_complete_rec.lead_sharing_status        := l_prtnr_prfls_rec.lead_sharing_status;
END IF;

IF p_prtnr_prfls_rec.lead_share_appr_flag    is null  THEN
   x_complete_rec.lead_share_appr_flag        := l_prtnr_prfls_rec.lead_share_appr_flag;
END IF;

IF p_prtnr_prfls_rec.partner_relationship_id  is null  THEN
   x_complete_rec.partner_relationship_id    := l_prtnr_prfls_rec.partner_relationship_id;
END IF;

IF p_prtnr_prfls_rec.partner_level  is null  THEN
   x_complete_rec.partner_level    := l_prtnr_prfls_rec.partner_level;
END IF;

IF p_prtnr_prfls_rec.preferred_vad_id is null  THEN
   x_complete_rec.preferred_vad_id    := l_prtnr_prfls_rec.preferred_vad_id;
END IF;

IF p_prtnr_prfls_rec.partner_group_id is null  THEN
   x_complete_rec.partner_group_id    := l_prtnr_prfls_rec.partner_group_id;
END IF;

IF p_prtnr_prfls_rec.partner_resource_id is null  THEN
   x_complete_rec.partner_resource_id    := l_prtnr_prfls_rec.partner_resource_id;
END IF;

IF p_prtnr_prfls_rec.partner_group_number is null  THEN
   x_complete_rec.partner_group_number    := l_prtnr_prfls_rec.partner_group_number;
END IF;

IF p_prtnr_prfls_rec.partner_resource_number is null  THEN
   x_complete_rec.partner_resource_number    := l_prtnr_prfls_rec.partner_resource_number;
END IF;

IF p_prtnr_prfls_rec.sales_partner_flag    is null  THEN
   x_complete_rec.sales_partner_flag        := l_prtnr_prfls_rec.sales_partner_flag;
END IF;

IF p_prtnr_prfls_rec.indirectly_managed_flag  is null  THEN
   x_complete_rec.indirectly_managed_flag   := l_prtnr_prfls_rec.indirectly_managed_flag;
END IF;

IF p_prtnr_prfls_rec.channel_marketing_manager is null  THEN
   x_complete_rec.channel_marketing_manager := l_prtnr_prfls_rec.channel_marketing_manager;
END IF;

IF p_prtnr_prfls_rec.related_partner_id      is null  THEN
   x_complete_rec.related_partner_id          := l_prtnr_prfls_rec.related_partner_id;
END IF;

IF p_prtnr_prfls_rec.max_users            is null  THEN
   x_complete_rec.max_users                   := l_prtnr_prfls_rec.max_users;
END IF;

IF p_prtnr_prfls_rec.partner_party_id     is null  THEN
   x_complete_rec.partner_party_id            := l_prtnr_prfls_rec.partner_party_id;
END IF;


END Complete_Prtnr_Prfls_Rec;

-- Start of Comments
--
--      Funtion name  : Upsert_Attr_Values
--      Type      : Private
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes: Upsert all the attributes for the partner, also take care of
--              creating the channel team and update the partner profile based
--              on business rules.
--
-- End of Comments
PROCEDURE Upsert_Attr_Values (
           p_entity_id          IN      NUMBER
          ,p_partner_attrs_tbl	IN		attr_details_tbl_type
          ,p_mode               IN  VARCHAR2
          ,x_exit_partner       OUT NOCOPY VARCHAR2

    ) IS

    l_bound         NUMBER;
    u_bound         NUMBER;
    l_partner_types_tbl     PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
    l_attr_values_tbl       PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type; --attr_values_tbl_type;
    l_attribute_id          NUMBER;
    l_version       NUMBER;

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR(2000);

    l_current_partner_level     VARCHAR2(30);
    l_new_partner_level         VARCHAR2(30);
    l_prtnr_prfls_rec           PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type;
    l_complete_prtnr_prfls_rec  PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type;
    l_partner_profile_id        NUMBER;

    l_update_channel_team       VARCHAR2(1);
    l_prtnr_qflr_flg_rec        PV_TERR_ASSIGN_PUB.prtnr_qflr_flg_rec_type;
    l_prtnr_access_id_tbl       PV_TERR_ASSIGN_PUB.prtnr_aces_tbl_type;
    l_log_params_tbl	        PVX_UTILITY_PVT.log_params_tbl_type;
    l_current_partner_type      varchar2(30);
    l_new_partner_type          varchar2(30);
    l_update_history            VARCHAR2(1);
    l_new_partner_level_id      number;



   CURSOR l_get_attr_version(cv_entity_id IN NUMBER, cv_attr_id IN Number) IS
        SELECT
            	max(version)
		FROM
    			pv_enty_attr_values
    	WHERE
    			attribute_id = cv_attr_id and
    			entity_id = cv_entity_id;


   CURSOR l_get_partner_level(cv_partner_id  IN number) is
        select
                attr_code
        from
                pv_partner_profiles val,
                pv_attribute_codes_b cod
        where
                cod.attr_code_id = val.partner_level and
                val.partner_id = cv_partner_id;


    CURSOR l_get_partner_level_id(cv_partner_level_cd IN varchar2) IS
        select
                attr_code_id
        from
                pv_attribute_codes_b
        where
                attr_code = cv_partner_level_cd;

    CURSOR l_get_partner_profile_id(cv_partner_id IN varchar2) IS
        select
                partner_profile_id
        from
                pv_partner_profiles
        where
                partner_id = cv_partner_id;

    CURSOR l_get_partner_type(cv_partner_id IN NUMBER) IS
        select
                attr_value
        from
                pv_enty_attr_values
        where
                entity_id    = cv_partner_id and
                attribute_id = 3 and
                latest_flag = 'Y';

BEGIN

--dbms_output.put_line('Processing Upsert ');

    l_bound := p_partner_attrs_tbl.first;
    u_bound := p_partner_attrs_tbl.last;

    l_current_partner_type := null;
    OPEN l_get_partner_type(p_entity_id);
    fetch l_get_partner_type into l_current_partner_type;
    close l_get_partner_type;

    for i in l_bound..u_bound
    loop

            l_attribute_id := p_partner_attrs_tbl(i).attribute_id;
            l_attr_values_tbl := p_partner_attrs_tbl(i).attr_values_tbl;

            for j in l_attr_values_tbl.first..l_attr_values_tbl.last
            loop
                  l_partner_types_tbl(j).attr_value := l_attr_values_tbl(j).attr_value;
                  l_partner_types_tbl(j).attr_value_extn := l_attr_values_tbl(j).attr_value_extn;

                  if l_attribute_id = 19 then
                        l_new_partner_level := l_attr_values_tbl(j).attr_value;
                  end if;
                  if l_attribute_id = 3 then
                        l_new_partner_type := l_attr_values_tbl(j).attr_value;
                        l_partner_types_tbl(j).attr_value_extn := 'Y';
                        if l_current_partner_type <> l_new_partner_type then
                            l_update_channel_team := 'Y';
                            l_update_history := 'Y';
                        end if;
                  end if;
            end loop;

            l_version := null;
            OPEN l_get_attr_version(p_entity_id,p_partner_attrs_tbl(i).attribute_id);
            FETCH l_get_attr_version INTO l_version;
            close l_get_attr_version;

            if l_version is null then
                l_version := 0;
            end if;

--dbms_output.put_line('Finished setting channel team flag ');
            IF NOT (p_mode = 'CREATE' AND (l_attribute_id = 3 or l_attribute_id = 6)) THEN
                If l_attribute_id <> 19 then
                    --dbms_output.put_line('Calling upsert for : ' || l_attribute_id);
                    --dbms_output.put_line('ATTR VALUE EXTN: ' || l_partner_types_tbl(1).attr_value_extn);
                    PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value (
                             p_api_version_number=> 1.0
                             ,p_init_msg_list    => FND_API.g_true
                             ,p_commit           => FND_API.g_false
                             ,p_validation_level => FND_API.g_valid_level_full
                             ,x_return_status    => l_return_status
                             ,x_msg_count        => l_msg_count
                             ,x_msg_data         => l_msg_data
                             ,p_attribute_id     => l_attribute_id
                             ,p_entity	         => 'PARTNER'
                             ,p_entity_id	     => p_entity_id
                             ,p_version          => l_version
                             ,p_attr_val_tbl     => l_partner_types_tbl
                          );

                            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                --FOR l_msg_index IN 1..l_msg_count LOOP
                                    apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_count));
                                    l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                    l_error_count := l_error_count +1;
                                    --dbms_output.put_line(substr(apps.fnd_message.get,1,254));
                               -- END LOOP;
                                x_exit_partner  := 'TRUE';
                                l_update_channel_team := 'N';
                            END IF;
                end if;
            end if;

            if (l_attribute_id = 19) then
                    OPEN  l_get_partner_level(p_entity_id);
                    FETCH l_get_partner_level into l_current_partner_level;

                    if l_get_partner_level%notfound then
                        l_current_partner_level := 'N/A';
                    end if;

                    close l_get_partner_level;
                    if l_new_partner_level <> l_current_partner_level then

                        l_partner_profile_id    := null;
                        l_new_partner_level_id  := null;

                        OPEN l_get_partner_profile_id(p_entity_id);
                        FETCH l_get_partner_profile_id into l_partner_profile_id;
                        CLOSE l_get_partner_profile_id;


                        OPEN l_get_partner_level_id(l_new_partner_level);
                        FETCH l_get_partner_level_id into l_new_partner_level_id;
                        close l_get_partner_level_id;

                        l_prtnr_prfls_rec.partner_profile_id := l_partner_profile_id;

                        BEGIN

                        Complete_Prtnr_Prfls_Rec(
                               p_prtnr_prfls_rec    =>  l_prtnr_prfls_rec
                              ,x_complete_rec       =>  l_complete_prtnr_prfls_rec);

                        l_complete_prtnr_prfls_rec.partner_level := l_new_partner_level_id;
                        PVX_PRTNR_PRFLS_PVT.Update_Prtnr_Prfls(
                                      p_api_version      => 1.0
                                     ,p_init_msg_list    => FND_API.g_true
                                     ,p_commit           => FND_API.g_false
                                     ,p_validation_level => FND_API.g_valid_level_full
                                     ,x_return_status    => l_return_status
                                     ,x_msg_count        => l_msg_count
                                     ,x_msg_data         => l_msg_data
                                     ,p_prtnr_prfls_rec  =>  l_complete_prtnr_prfls_rec);

                        EXCEPTION

                            WHEN FND_API.g_exc_error THEN
                                l_return_status := FND_API.g_ret_sts_error;
                                FND_MSG_PUB.count_and_get (
                                   p_encoded => FND_API.g_false
                                  ,p_count   => l_msg_count
                                  ,p_data    => l_msg_data
                                  );
                                --dbms_output.put_line('Message : ' || l_msg_data );
                            WHEN FND_API.g_exc_unexpected_error THEN
                                l_return_status := FND_API.g_ret_sts_unexp_error ;
                                FND_MSG_PUB.count_and_get (
                                   p_encoded => FND_API.g_false
                                  ,p_count   => l_msg_count
                                  ,p_data    => l_msg_data
                                  );
                                --dbms_output.put_line('Message : ' || l_msg_data );
                            WHEN OTHERS THEN
                                l_return_status := FND_API.g_ret_sts_unexp_error ;
                                FND_MSG_PUB.count_and_get (
                                   p_encoded => FND_API.g_false
                                  ,p_count   => l_msg_count
                                  ,p_data    => l_msg_data
                                  );
                            END;

                        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                            FOR l_msg_index IN 1..l_msg_count LOOP
                                apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
                                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                l_error_count := l_error_count +1;
                                --dbms_output.put_line(substr(apps.fnd_message.get,1,254));
                            END LOOP;
                            x_exit_partner  := 'TRUE';
                        else
                            l_update_channel_team := 'Y';
                        end if;
                    end if;
            end if;

       end loop;


        if l_update_channel_team = 'Y' then

            PV_TERR_ASSIGN_PUB.Update_Channel_Team
            (
                p_api_version_number     => 1.0,
                p_init_msg_list    => FND_API.g_true,
                p_commit           => FND_API.g_false,
                p_validation_level => FND_API.g_valid_level_full,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_partner_id       => p_entity_id,
                p_vad_partner_id   => Null,
                p_mode             => 'UPDATE',
                p_login_user       => Null,
                p_upd_prtnr_qflr_flg_rec  => l_prtnr_qflr_flg_rec,
                x_prtnr_access_id_tbl     => l_prtnr_access_id_tbl
              );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    FOR l_msg_index IN 1..l_msg_count LOOP
                        apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
                        l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                        l_error_count := l_error_count +1;
                        --dbms_output.put_line(substr(apps.fnd_message.get,1,254));
                    END LOOP;
                        x_exit_partner  := 'TRUE';
                    END IF;
        end if;

        IF l_update_history = 'Y' then

                --dbms_output.put_line('udpating history ');
                l_log_params_tbl(1).param_name  := 'ORIGINAL';
                l_log_params_tbl(1).param_value := l_current_partner_type;
                l_log_params_tbl(2).param_name  := 'CURRENT';
                l_log_params_tbl(2).param_value := l_new_partner_type;

                PVX_UTILITY_PVT.create_history_log(
                  p_arc_history_for_entity_code  	=> 'GENERAL',
                  p_history_for_entity_id  	        => p_entity_id,
                  p_history_category_code		    => 'PARTNER',
                  p_message_code			        => 'PV_PRIMARY_PARTNER_TYPE_CHANGE',
                  p_partner_id                      => p_entity_id,
                  p_access_level_flag               => 'V',
                  p_interaction_level               => PVX_Utility_PVT.G_INTERACTION_LEVEL_50,
                  p_comments			            => Null,
                  p_log_params_tbl		            => l_log_params_tbl,
                  p_init_msg_list                   => FND_API.g_true,
                  p_commit                          => FND_API.g_false,
                  x_return_status    	            => l_return_status,
                  x_msg_count                       => l_msg_count,
                  x_msg_data                        => l_msg_data
                );
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    FOR l_msg_index IN 1..l_msg_count LOOP
                        apps.fnd_message.set_encoded(apps.fnd_msg_pub.get(l_msg_index));
                        l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                        l_error_count := l_error_count +1;
                        --dbms_output.put_line(substr(apps.fnd_message.get,1,254));
                    END LOOP;
                    x_exit_partner  := 'TRUE';
                END IF;
        end if;

--dbms_output.put_line('Getting out of upsert ');

END Upsert_Attr_Values;

-- Start of Comments
--
--      Funtion name  : Load_Partners
--      Type      : Public
--      Function  :
--
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Public API to load all the partners and their attributes. API will
--               do all the business validations and log all the messages.
--
--
-- End of Comments
PROCEDURE Load_Partners
     (
      p_api_version_number      IN  NUMBER
     ,p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
     ,p_mode         	        IN  VARCHAR2
     ,p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
     ,x_return_status           OUT NOCOPY  VARCHAR2
     ,x_msg_data                OUT NOCOPY  VARCHAR2
     ,x_msg_count               OUT NOCOPY  NUMBER
     ,p_partner_details_tbl	    IN  partner_details_tbl_type
     ,p_update_if_exists		IN 	varchar2
     ,p_data_block_size		        IN	number
     ,x_file_name			    OUT	NOCOPY varchar2
     ,x_partner_output_tbl      OUT NOCOPY partner_output_tbl_type) IS


    -- Get the value of Profile  PV_IMPORT_COMMIT_SIZE.
    CURSOR l_get_commit_size_csr(cv_profile_name IN VARCHAR2) IS
    SELECT nvl(fnd_profile.value(cv_profile_name),0) from dual;

    CURSOR l_get_party_id(cv_orig_system IN VARCHAR2, cv_orig_system_ref IN VARCHAR2) IS
     SELECT
    				HZ_PARTIES.PARTY_ID

    				FROM
    					HZ_ORIG_SYS_REFERENCES,
    					HZ_PARTIES

    				WHERE
    				    HZ_ORIG_SYS_REFERENCES.OWNER_TABLE_ID = HZ_PARTIES.PARTY_ID AND
    				    HZ_PARTIES.PARTY_TYPE = 'ORGANIZATION' AND
    					HZ_ORIG_SYS_REFERENCES.orig_system = cv_orig_system AND
    					HZ_ORIG_SYS_REFERENCES.orig_system_reference = cv_orig_system_ref AND
    					HZ_ORIG_SYS_REFERENCES.owner_table_name = 'HZ_PARTIES' AND
                        HZ_PARTIES.STATUS = 'A';


    CURSOR l_get_partner_id(cv_party_id IN NUMBER) IS
        SELECT
    				partner_id

    				FROM
    				    pv_partner_profiles

    				WHERE
    				    partner_party_id = cv_party_id;
--                        and status = 'A';


    CURSOR l_get_file_dir IS
    select
        trim(substr(value,0,(instr(value,',') - 1))),
        trim(substr(value,(instr(value,',') + 1)))
    from  v$parameter where name = 'utl_file_dir';


    l_data_block_size							NUMBER;
    l_partnersProcessedCount				Number;
    l_orig_system			    			VARCHAR2(30);
    l_orig_system_ref       				VARCHAR2(250);
    l_partner_name							VARCHAR2(360);
    l_attributes_count						NUMBER;
    l_exit_partner 							VARCHAR2(10);
    l_lower_limit                           NUMBER;
    l_upper_limit                           NUMBER;
    l_batch_count                           NUMBER;
    l_party_id                              NUMBER;
    l_out_party_id                          NUMBER;
    l_partner_id                            NUMBER;
    l_out_partner_id                        NUMBER;
    l_mode                                  VARCHAR2(10);
    l_running_mode                          varchar2(20);
    l_update_if_exists                      VARCHAR2(1);
    l_status                                varchar2(10);
    l_NS                                    varchar2(20);
    l_attribute_details_tbl                 attr_details_tbl_type;
--    l_attr_error_tbl                        error_tbl_type;

    l_return_status                         VARCHAR2(1);
    l_msg_count                             NUMBER;
    l_msg_data                              VARCHAR(2000);

    l_file_name                             varchar2(20);
    l_log_dir                               varchar2(100);
    l_out_dir                               varchar2(100);
    l_prof                                  varchar2(1);

BEGIN

        BEGIN
            l_prof := fnd_profile.value('HZ_EXECUTE_API_CALLOUTS');
            if l_prof <> 'N' then
                fnd_profile.put('HZ_EXECUTE_API_CALLOUTS','N');
            end if;

            IF p_mode is null then
                l_running_mode := 'EVALUATION';
            else
                l_running_mode := p_mode;
            END IF;
            l_partnersProcessedCount := 0;
            select to_char(systimestamp,'yyddmmsssss') || '.log'  into l_file_name from dual;
--            l_file_name := 'myLogFile.log';
            open l_get_file_dir;
            fetch l_get_file_dir into l_out_dir, l_log_dir;
            close l_get_file_dir;

--            UTL_FILE.fclose_all;
            l_log_file := utl_file.fopen(trim(l_out_dir), l_file_name, 'w',32767);


    /*
    Check if the commit size is passed. If not take it from the profile setting.
    if the profile is also not set then hard code the value to 50
    */
            if (p_data_block_size is Null or p_data_block_size = 0) then
            	l_data_block_size := g_data_block_size;
            else
            	l_data_block_size := p_data_block_size;
            end if;
            --dbms_output.put_line('Commit Size ' || l_data_block_size);

        	if p_partner_details_tbl.Count > 0 then

            	l_batch_count := ceil(p_partner_details_tbl.Count/l_data_block_size);
            	l_lower_limit := 1;
            	l_upper_limit := ceil(p_partner_details_tbl.Count/l_batch_count);

            	for batch_ident in 1..l_batch_count
            	loop
                    if batch_ident <> 1 then
                        l_lower_limit := l_upper_limit + 1;
                        l_upper_limit := ceil(batch_ident*(p_partner_details_tbl.Count/l_batch_count));
                    end if;

                    fnd_message.set_name('PV', 'PV_IMP_SUMMARY');
    		        utl_file.put_line(L_LOG_FILE, substrb(fnd_message.get, 1, 1000));

                    SAVEPOINT Batch;
                	for partner_ident in l_lower_limit..l_upper_limit
                		loop
                			SAVEPOINT Partner;
                			l_exit_partner := 'FALSE';
                			l_error_count := 1;

                			l_orig_system 			:= p_partner_details_tbl(partner_ident).orig_system;
                			l_orig_system_ref := p_partner_details_tbl(partner_ident).orig_system_ref;
                			l_partner_name 				:= p_partner_details_tbl(partner_ident).partner_name;
                			l_attributes_count 			:= p_partner_details_tbl(partner_ident).attribute_details_tbl.count();
                			l_party_id                  := p_partner_details_tbl(partner_ident).party_id;
                			l_partner_id                := p_partner_details_tbl(partner_ident).partner_id;


                            Validate_Party(
                                        p_party_id => l_party_id,
                                        p_orig_sys => l_orig_system,
                                        p_orig_sys_ref => l_orig_system_ref,
                                        p_partner_id => l_partner_id,
                                        p_partner_name => l_partner_name,
                                        p_type   => Null,
                                        x_party_id  => l_out_party_id,
                                        x_exit_partner => l_exit_partner
                            );

                            l_party_id := l_out_party_id;

                            --dbms_output.put_line('out of validate party ');
                           if l_partner_name is null OR (nvl(length(trim(l_partner_name)),0) = 0) then
                    			l_exit_partner := 'TRUE';
                    			fnd_message.set_name('PV', 'PV_IMP_REQ_DATA');
    			                fnd_message.set_token( 'PARAM', 'Partner Name');
                                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                l_error_count := l_error_count +1;

                    			--dbms_output.put_line('l_partner_name missing ');
                            end if;
                    		--dbms_output.put_line('done checking parnter name ');
                			if l_attributes_count = 0  then
                                fnd_message.set_name('PV', 'PV_IMP_REQ_DATA');
                                fnd_message.set_token( 'PARAM', 'Partner attributes' );
                                l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                l_error_count := l_error_count +1;
                                l_exit_partner := 'TRUE';
                                --dbms_output.put_line('l_attributes_count missing ');
                            end if;
                			--dbms_output.put_line('done checking attr count ');
                			if l_exit_partner = 'TRUE' then
                				goto end_of_partner_loop;
                			end if;
                            OPEN l_get_partner_id(l_party_id);
                            FETCH l_get_partner_id into l_partner_id;
                            if l_get_partner_id%found then
                                if l_get_partner_id%rowcount > 1 then
                                    if p_partner_details_tbl(partner_ident).partner_id is null then

                                        fnd_message.set_name('PV', 'PV_IMP_MULT_PTNR');
                                        l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                        l_error_count := l_error_count +1;
                                        l_exit_partner := 'TRUE';
                                        goto end_of_partner_loop;
                                    else
                                        l_partner_id := p_partner_details_tbl(partner_ident).partner_id;
                                    end if;
                                end if;
                                l_mode := 'UPDATE';
                            else
                                l_mode := 'CREATE';
                            end if;
                            close l_get_partner_id;
                            --dbms_output.put_line('finished gettting partner id ');
                            if l_mode = 'CREATE' then

                                Validate_And_Create_Partner(
                                    p_party_id              => l_party_id,
                                    p_partner_details_rec   => p_partner_details_tbl(partner_ident),
                                    x_partner_id          => l_out_partner_id,
                                    x_exit_partner   => l_exit_partner);

                                    l_partner_id := l_out_partner_id;
                                    --dbms_output.put_line('Created Partner Id ' || l_partner_id);



                            else

                                if p_partner_details_tbl(partner_ident).Update_If_Exists is null then
                                    l_update_if_exists := p_partner_details_tbl(partner_ident).Update_If_Exists;
                                else
                                    l_update_if_exists := p_update_if_exists;
                                end if;

                                if NOT (l_update_if_exists = 'Y') then
                                    fnd_message.set_name('PV', 'PV_IMP_PTNR_EXISTS');
                                    l_errors_tbl(l_error_count) := substrb(fnd_message.get, 1, 1000);
                                    l_error_count := l_error_count +1;
                                    --dbms_output.put_line('Partner attributes already exists.');
                                    goto end_of_partner_loop;
                                end if;
                                --dbms_output.put_line('calling update for attrs');
                                Validate_Update_Attributes(
                                    p_partner_details_rec   => p_partner_details_tbl(partner_ident),
                                    p_partner_id            => l_partner_id,
                                    x_exit_partner      => l_exit_partner);

                        end if;

                            /************************** Invoke Shome's attr validation routine */
/*
                               validate_attribute
                                ( in_table =>  p_partner_details_tbl(partner_ident).attribute_details_tbl,
                                  out_table => l_attribute_details_tbl,
                                  err_table => l_attr_error_tbl );
                                if l_attr_error_tbl.count > 0 then
                                    l_exit_partner := 'TRUE';
                                    for i in 1..l_attr_error_tbl.count
                                    loop
                                        l_errors_tbl(l_error_count) := l_attr_error_tbl(i).error_desc;
                                        l_error_count := l_error_count + 1;
                                    end loop;
                                end if;
*/
                            /*****************************Ends here*************************/


                            --dbms_output.put_line('l_exit_partner:  ' || l_exit_partner);
                            if l_exit_partner = 'TRUE' then
                                Rollback TO Partner;
                                goto end_of_partner_loop;
                            end if;


                            --dbms_output.put_line('Calling upsert attrs ');
                            Upsert_Attr_Values (
                                   p_entity_id          => l_partner_id,
                                   --p_partner_attrs_tbl	=> l_attribute_details_tbl, --p_partner_details_tbl(partner_ident).attribute_details_tbl,
                                    p_partner_attrs_tbl	=> p_partner_details_tbl(partner_ident).attribute_details_tbl,
                                   p_mode               => l_mode,
                                   x_exit_partner    => l_exit_partner);

                                if l_exit_partner = 'TRUE' then
                                    Rollback TO Partner;
                                    goto end_of_partner_loop;
                                end if;

                	      <<end_of_partner_loop>>

                	       if l_exit_partner = 'TRUE' then
                	           l_status := 'ERROR';
                	       elsif l_mode = 'CREATE' THEN
                	           l_status := 'CREATED';
                	       else
                    	       l_status := 'UPDATED';
                	       end if;

                            if l_running_mode = 'EXECUTION' then
                                l_partnersProcessedCount := l_partnersProcessedCount + 1;
                                x_partner_output_tbl(l_partnersProcessedCount).orig_system := l_orig_system;
                                x_partner_output_tbl(l_partnersProcessedCount).orig_system_ref := l_orig_system_ref;
                                x_partner_output_tbl(l_partnersProcessedCount).party_id := l_party_id;
                                x_partner_output_tbl(l_partnersProcessedCount).partner_id := l_partner_id;
                                x_partner_output_tbl(l_partnersProcessedCount).return_status := l_status;
                            end if;

                            --dbms_output.put_line('writing partner id ' || l_partner_id );
                            fnd_message.set_name('PV', 'PV_IMP_NOT_SUPL');
                            l_ns := substrb(fnd_message.get, 1, 1000);
    		                utl_file.put_line(L_LOG_FILE, rpad(nvl(l_partner_name,l_ns),30) || rpad(nvl(l_orig_system,l_ns),20) || rpad(nvl(l_orig_system_ref,l_ns),20) || rpad(nvl(to_char(l_party_id),l_ns),20) ||
    		                				rpad(nvl(to_char(l_partner_id),l_ns),20) || rpad(nvl(l_status,l_ns),20));
                            Write_Error();
    		                utl_file.put_line(L_LOG_FILE, '------------------------------------------------------------------------------------------------------------------------------------------------------');
                		end loop;

                        if l_running_mode = 'EXECUTION' then
                          commit;
                            --dbms_output.put_line('Commiting ');
                        else
                          --dbms_output.put_line('Rolling back ');
                            Rollback to Batch;

                        end if;

                end loop;
        else
            fnd_message.set_name('PV', 'PV_IMP_NO_PARTNER');
    		utl_file.put_line(L_LOG_FILE, substrb(fnd_message.get, 1, 1000));
    		--dbms_output.put_line('No partner data has been passed');
        end if;

        if l_prof <> 'N' then
            fnd_profile.put('HZ_EXECUTE_API_CALLOUTS',l_prof);
        end if;

        x_file_name := l_out_dir || '/' || l_file_name;
        --dbms_output.put_line('output file name  ' || x_file_name);
        utl_file.fclose(l_log_file);


    EXCEPTION
    when utl_file.invalid_path then
         raise_application_error(-20100,'Invalid Path');
      when utl_file.invalid_mode then
         raise_application_error(-20101,'Invalid Mode');
      when utl_file.invalid_operation then
         raise_application_error(-20102,'Invalid Operation');
      when utl_file.invalid_filehandle then
         raise_application_error(-20103,'Invalid FileHandle');
      when utl_file.write_error then
         utl_file.fclose(l_log_file);
         raise_application_error(-20104,'Write Error');
      when utl_file.read_error then
         raise_application_error(-20105,'Read Error');
      when utl_file.internal_error then
         raise_application_error(-20106,'Internal Error');

    WHEN OTHERS THEN
            --dbms_output.put_line('Exception Occured ' || SQLERRM);
            ROLLBACK;
    		utl_file.put_line(L_LOG_FILE,SQLERRM);
            FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
              utl_file.put_line(L_LOG_FILE,Substr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ),1,1000));
              --dbms_output.put_line('error handling ');
            END LOOP;
            utl_file.fclose(l_log_file);


    END;


END Load_Partners;

END PV_PARTNER_ATTR_LOAD_PUB;




/
