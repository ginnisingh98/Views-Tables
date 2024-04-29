--------------------------------------------------------
--  DDL for Package Body PER_TMPROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TMPROFILE_PKG" as
/* $Header: pertppkg.pkb 120.0.12010000.2 2009/04/17 15:26:07 gkochhar noship $ */
  function is_subordinate (p_subordinate_person_id    in number
                          ,p_person_id                in number
                          ,p_effective_date           in date
                          ) return varchar2 as
    l_supervisor_id      number;
    l_current_person_id  number;
  begin
    l_current_person_id := p_subordinate_person_id;
    loop
      begin
        select supervisor_id
          into l_supervisor_id
          from per_all_assignments_f
         where per_all_assignments_f.person_id = l_current_person_id
           and per_all_assignments_f.primary_flag = 'Y'
           and per_all_assignments_f.assignment_type in ('E','C')
           and per_all_assignments_f.assignment_status_type_id not in
             (select assignment_status_type_id
                from per_assignment_status_types
               where per_system_status = 'TERM_ASSIGN')
           and trunc(p_effective_date)
               between per_all_assignments_f.effective_start_date
                   and per_all_assignments_f.effective_end_date;
      exception
        when no_data_found then
          return 'N';
      end;

      if l_supervisor_id is null then
        return 'N';
      end if;
      if l_supervisor_id = p_person_id then
        return 'Y';
      end if;
      l_current_person_id := l_supervisor_id;
    end loop;
  end is_subordinate;

  function get_address (p_person_id       in number
                       ,p_effective_date  in date
                       ) return varchar2 as
    l_address_line1 per_addresses.address_line1%type;
    l_address_line2 per_addresses.address_line2%type;
    l_address_line3 per_addresses.address_line3%type;
    l_region_1 per_addresses.region_1%type;
    l_region_2 per_addresses.region_2%type;
    l_region_3 per_addresses.region_3%type;
    l_town_or_city per_addresses.town_or_city%type;
    l_postal_code per_addresses.postal_code%type;
    l_country per_addresses.country%type;

    l_address varchar2(1000) := null;
  begin
    select address_line1,
           address_line2,
           address_line3,
           region_1,
           region_2,
           region_3,
           town_or_city,
           postal_code,
           country
      into l_address_line1,
           l_address_line2,
           l_address_line3,
           l_region_1,
           l_region_2,
           l_region_3,
           l_town_or_city,
           l_postal_code,
           l_country
      from per_addresses
     where person_id = p_person_id
       and primary_flag = 'Y'
       and p_effective_date
           between date_from
               and nvl(date_to,p_effective_date);

    if l_address_line1 is not null then
      l_address := l_address_line1;
    end if;

    if l_address_line2 is not null then
      if l_address is null then
        l_address := l_address_line2;
      else
        l_address := l_address || ',' || l_address_line2;
      end if;
    end if;

    if l_address_line3 is not null then
      if l_address is null then
        l_address := l_address_line3;
      else
        l_address := l_address || ',' || l_address_line3;
      end if;
    end if;

    if l_region_1 is not null then
      if l_address is null then
         l_address := l_region_1;
      else
        l_address := l_address || ',' || l_region_1;
      end if;
    end if;

    if l_region_2 is not null then
      if l_address is null then
        l_address := l_region_2;
      else
        l_address := l_address || ',' || l_region_2;
      end if;
    end if;

    if l_region_3 is not null then
      if l_address is null then
        l_address := l_region_3;
      else
        l_address := l_address || ',' || l_region_3;
      end if;
    end if;

   if l_town_or_city is not null then
      if l_address is null then
        l_address := l_town_or_city;
      else
        l_address := l_address || ',' || l_town_or_city;
      end if;
    end if;

    if l_postal_code is not null then
      if l_address is null then
        l_address := l_postal_code;
      else
        l_address := l_address || ',' || l_postal_code;
      end if;
    end if;

    if l_country is not null then
      if l_address is null then
        l_address := l_country;
      else
        l_address := l_address || ',' || l_country;
      end if;
    end if;

    return l_address;
  exception
    when no_data_found then
      return '-';
    when too_many_rows then
      return '<Too Many Rows>';
  end get_address;

  function encode64 (p_blob in blob) return clob as
    l_result clob;
  begin
    if p_blob is not null then
      dbms_lob.createtemporary
        (lob_loc  => l_result
        ,cache    => false
        ,dur      => 0);
      wf_mail_util.encodeblob (p_blob,l_result);
    end if ;
    return l_result;
  end encode64;

FUNCTION get_value_for_9box(p_person_id IN NUMBER,
                            p_effective_date IN DATE,
                            p_type IN VARCHAR2) RETURN NUMBER IS
  l_value NUMBER(15);
  l_performance NUMBER(15);
  l_potential NUMBER(15);
  l_retention NUMBER(15);
  BEGIN
   l_performance  := hr_wpm_util.get_performance_for_9box(p_person_id,p_effective_date);
   l_potential    := hr_wpm_util.get_potential_for_9box(p_person_id,p_effective_date);
   l_retention    := hr_wpm_util.get_retention_for_9box(p_person_id,p_effective_date);

  IF l_performance > 0 THEN
   IF (p_type = 'POT' and l_potential >0) THEN
      l_value := ((l_potential-1)*3 + l_performance);
   ELSIF (p_type = 'RET' and l_retention >0) THEN
      l_value := ((l_retention-1)*3 + l_performance);
   ELSE
   l_value := 0;
   END IF;
  ELSE
	l_value := 0;


  END IF;

  return l_value;
END get_value_for_9box;


end per_tmprofile_pkg;

/
