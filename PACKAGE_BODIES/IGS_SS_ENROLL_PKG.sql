--------------------------------------------------------
--  DDL for Package Body IGS_SS_ENROLL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_ENROLL_PKG" as
/* $Header: IGSSS04B.pls 120.0 2005/06/01 18:33:09 appldev noship $ */

PROCEDURE insert_into_enr_cart
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_person_id  in  varchar2,
   p_cal_type in varchar2,
   p_ci_sequence_number in varchar2,
   p_call_number in varchar2,
   p_org_id in number
)
is
lv_count number := 0 ;
begin
    select count(*) into lv_count
    from igs_ss_su_selection
    where person_id = p_person_id
    and   call_number = p_call_number
    and   cal_type = p_cal_type
    and   ci_sequence_number = p_ci_sequence_number ;
    if lv_count = 0
    then
	begin
	insert into igs_ss_su_selection
        (
          usec_su_selection_id       ,
          person_id                  ,
          unit_cd                    ,
          version_number             ,
          cal_type                   ,
          ci_sequence_number         ,
          location_cd                ,
          unit_class                 ,
          uoo_id                     ,
	    call_number			 ,
          enrolled_dt                ,
          enrolled_cp                ,
          grading_schema_cd          ,
          unit_attempt_status        ,
          created_by                 ,
          creation_date              ,
          last_updated_by            ,
          last_update_date           ,
          last_update_login          ,
          org_id
        )
	select
	igs_ss_su_selection_s.nextval,
	    p_person_id,
  	    unit_cd,
	    version_number             ,
          cal_type                   ,
          ci_sequence_number         ,
          location_cd                ,
          unit_class                 ,
          uoo_id                     ,
          call_number                ,
          sysdate				 ,
          null				 ,
          null				 ,
          'CART'				 ,
          p_person_id			 ,
          sysdate				 ,
          p_person_id			 ,
          sysdate				 ,
          p_person_id		     ,
          p_org_id
	from igs_ps_unit_ofr_opt
	where cal_type = p_cal_type
	and   ci_sequence_number = p_ci_sequence_number
	and   call_number = p_call_number ;
	if sql%rowcount = 0
	then
        fnd_message.set_name('IGS','IGS_SS_SU_NO_UNITS_FOUND');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
	end if ;
	exception
        when others
	then
--	        fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
	        fnd_message.set_name('IGS',sqlerrm);
	        fnd_msg_pub.add;
	        p_return_status :=  fnd_api.g_ret_sts_error;
	end ;
      else
	   fnd_message.set_name('IGS','IGS_SS_SU_SELECTION_PK');
	   fnd_msg_pub.add;
	   p_return_status :=  fnd_api.g_ret_sts_error;
      end if ;

      fnd_msg_pub.count_and_get
      (
         p_count		=> p_msg_count,
         p_data		=> p_msg_data
      );
end insert_into_enr_cart;

PROCEDURE insert_into_enr_cart
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_insert_flag out NOCOPY varchar2,
   p_person_id  in  varchar2,
   p_cal_type in varchar2,
   p_ci_sequence_number in varchar2,
   p_unit_cd in varchar2,
   p_unit_class in varchar2,
   p_org_id in number
)
is
lv_count number(2) := 0 ;
begin
	begin
	select
	count(unit_cd)
	into lv_count
	from igs_ps_unit_ofr_opt
	where cal_type = p_cal_type
	and   ci_sequence_number = p_ci_sequence_number
	and   lower(unit_cd) = lower(p_unit_cd)
	and   lower(unit_class) = lower(p_unit_class);
      if lv_count = 0
      then
	        fnd_message.set_name('IGS','IGS_SS_SU_NO_UNITS_FOUND');
      	  fnd_msg_pub.add;
              p_return_status :=  fnd_api.g_ret_sts_error;
         	  p_insert_flag := 'NA' ;
      elsif lv_count = 1
      then
		begin
		insert into igs_ss_su_selection
	        (
          usec_su_selection_id       ,
      	    person_id                  ,
	          unit_cd                    ,
      	    version_number             ,
	          cal_type                   ,
      	    ci_sequence_number         ,
	          location_cd                ,
      	    unit_class                 ,
	          uoo_id                     ,
		    call_number			 ,
	          enrolled_dt                ,
      	    enrolled_cp                ,
	          grading_schema_cd          ,
      	    unit_attempt_status        ,
	          created_by                 ,
      	    creation_date              ,
	          last_updated_by            ,
      	    last_update_date           ,
	          last_update_login,
	          org_id
      	  )
		select
		igs_ss_su_selection_s.nextval,
		    p_person_id,
  		    unit_cd,
		    version_number             ,
      	    cal_type                   ,
	          ci_sequence_number         ,
      	    location_cd                ,
	          unit_class                 ,
      	    uoo_id                     ,
	          call_number                ,
      	    sysdate				 ,
	          null				 ,
      	    null				 ,
	          'CART'				 ,
      	    p_person_id			 ,
	          sysdate				 ,
      	    p_person_id			 ,
	          sysdate				 ,
      	    p_person_id,
      	    p_org_id
		from igs_ps_unit_ofr_opt
		where cal_type = p_cal_type
		and   ci_sequence_number = p_ci_sequence_number
		and   upper(unit_cd) = upper(p_unit_cd)
		and   upper(unit_class) = upper(p_unit_class) ;
            p_insert_flag := 'Y' ;
		if sql%rowcount = 0
		then
	        fnd_message.set_name('IGS','IGS_SS_SU_NO_UNITS_FOUND');
      	  fnd_msg_pub.add;
              p_return_status :=  fnd_api.g_ret_sts_error;
  		end if ;
		exception
	      when dup_val_on_index
		then
	        fnd_message.set_name('IGS','IGS_SS_SU_SELECTION_PK');
	        fnd_msg_pub.add;
	        p_return_status :=  fnd_api.g_ret_sts_error;
            end ;
      else
		p_insert_flag := 'N' ;
      end if ;
		exception when others
		then
	        fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
	        fnd_msg_pub.add;
	        p_return_status :=  fnd_api.g_ret_sts_error;
		end ;
      fnd_msg_pub.count_and_get
      (
         p_count		=> p_msg_count,
         p_data		=> p_msg_data
      );
end insert_into_enr_cart;

PROCEDURE insert_into_enr_cart
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_person_id  in  varchar2,
   p_uoo_id in varchar2,
   p_org_id in number
)
as
lv_count number := 0 ;
begin
    select count(*) into lv_count
    from igs_ss_su_selection
    where person_id = p_person_id
    and   uoo_id = p_uoo_id ;
    if lv_count = 0
    then
       begin
        insert into igs_ss_su_selection
        (
          usec_su_selection_id       ,
          person_id                  ,
          unit_cd                    ,
          version_number             ,
          cal_type                   ,
          ci_sequence_number         ,
          location_cd                ,
          unit_class                 ,
          uoo_id                     ,
	    call_number			 ,
          enrolled_dt                ,
          enrolled_cp                ,
          grading_schema_cd          ,
          unit_attempt_status        ,
          created_by                 ,
          creation_date              ,
          last_updated_by            ,
          last_update_date           ,
          last_update_login          ,
          org_id
        )
	  select
	  igs_ss_su_selection_s.nextval,
           p_person_id  ,
           a.unit_cd    ,
           a.version_number ,
           a.cal_type   ,
           a.ci_sequence_number ,
           a.location_cd ,
           a.unit_class ,
           a.uoo_id ,
	     a.call_number,
           sysdate,
           null,
           null,
           'CART',
           p_person_id,
           sysdate,
           p_person_id,
           sysdate,
           p_person_id,
           p_org_id
	  from igs_ps_unit_ofr_opt a
        where uoo_id = p_uoo_id ;
	  exception
        when dup_val_on_index
        then
        	fnd_message.set_name('IGS','IGS_SS_SU_SELECTION_PK');
	      fnd_msg_pub.add;
      	p_return_status :=  fnd_api.g_ret_sts_error;
	  when others
	  then
            fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
            fnd_msg_pub.add;
            p_return_status := fnd_api.g_ret_sts_error;
       end ;
    else
        fnd_message.set_name('IGS','IGS_SS_SU_SELECTION_PK');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
    end if ;
    fnd_msg_pub.count_and_get
    (
       p_count		=> p_msg_count,
       p_data		=> p_msg_data
     );
exception when others
then
  fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
  fnd_msg_pub.Add;
  p_return_status := fnd_api.g_ret_sts_error;
  fnd_msg_pub.count_and_get
  (
   p_count		=> p_msg_count,
   p_data		=> p_msg_data
  );
end insert_into_enr_cart;

PROCEDURE remove_from_shopping_cart
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_person_id  in  varchar2,
   p_uoo_id in varchar2,
   p_course_cd in varchar2
)
is
begin
    begin
    delete from igs_ss_su_selection
    where person_id = p_person_id
    and uoo_id = p_uoo_id ;
    if sql%rowcount = 0
    then
        fnd_message.set_name('IGS','IGS_SS_ENR_CART_NO_DELETE');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
    end if ;
    exception
    when too_many_rows
    then
	  fnd_message.set_name('IGS','IGS_SS_ENR_CART_TOO_MANY_ROWS');
	  fnd_msg_pub.Add;
	  p_return_status := fnd_api.g_ret_sts_error;
    when others
    then
	  fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
	  fnd_msg_pub.Add;
	  p_return_status := fnd_api.g_ret_sts_error;
    end ;
    fnd_msg_pub.count_and_get
    (
       p_count		=> p_msg_count,
       p_data		=> p_msg_data
     );
end remove_from_shopping_cart;

PROCEDURE insert_into_su_attempt
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_org_id   in number ,
   p_person_id  in  varchar2,
   p_course_cd in varchar2,
   p_uoo_id in varchar2,
   p_grading_schema in varchar2,
   p_enrolled_cp in varchar2
)
is
l_course_cd varchar2(6) ;
begin
if nvl(p_course_cd,' ') = ' '
then
    begin
	SELECT
	a.course_cd
	into l_course_cd
	from igs_en_stdnt_ps_att a
	where nvl(a.course_attempt_status,' ') not in ('INACTIVE')
	and person_id = p_person_id ;
	exception when others
	then
            fnd_message.set_name('IGS',sqlerrm);
            --fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
    	    fnd_msg_pub.add;
    	    p_return_status :=  fnd_api.g_ret_sts_error;
    end ;
else
	l_course_cd := p_course_cd ;
end if ;
	begin
	insert into igs_en_su_attempt
	(
	org_id,
	person_id,
	course_cd,
	unit_cd,
	version_number,
	cal_type,
	ci_sequence_number,
	location_cd,
	unit_class,
	ci_start_dt,
	ci_end_dt,
	uoo_id,
	unit_attempt_status,
	no_assessment_ind,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	override_achievable_cp
	)
	select
        p_org_id,
	p_person_id,
	l_course_cd,
	a.unit_cd,
	a.version_number,
	a.cal_type,
	a.ci_sequence_number,
	a.location_cd,
	a.unit_class,
	b.start_dt,
	b.end_dt,
	a.uoo_id,
	'ENROLLED',
	'N',
	p_person_id,
	sysdate,
	p_person_id,
	sysdate,
        p_enrolled_cp
	from igs_ps_unit_ofr_opt a,igs_ca_inst b
	where a.uoo_id = p_uoo_id
	and b.sequence_number = a.ci_sequence_number
	and b.cal_type = a.cal_type  ;
	if sql%rowcount = 0
	then
        fnd_message.set_name('IGS','IGS_SS_SU_NO_UNITS_FOUND');
     	  fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
	end if ;
	exception
      when dup_val_on_index
	then
        fnd_message.set_name('IGS','IGS_SS_SU_ENROLLMENT_PK');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
      when others
	then
        fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
      end ;

      begin
      delete from igs_ss_su_selection
      where person_id = p_person_id
	and  uoo_id = p_uoo_id ;
      if sql%rowcount = 0
	then
        fnd_message.set_name('IGS','IGS_SS_ENR_CART_NO_DELETE');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
      end if ;
      end ;

      fnd_msg_pub.count_and_get
      (
        p_count		=> p_msg_count,
        p_data		=> p_msg_data
      );

end insert_into_su_attempt;

PROCEDURE delete_from_su_attempt
(
   p_return_status out NOCOPY varchar2,
   p_msg_count out NOCOPY number,
   p_msg_data out NOCOPY varchar2,
   p_org_id   in number ,
   p_person_id  in  varchar2,
   p_course_cd in varchar2,
   p_uoo_id in varchar2
)
is
begin
    begin
    delete from igs_en_su_attempt
    where person_id = p_person_id
    and course_cd = p_course_cd
    and uoo_id = p_uoo_id
    and org_id = p_org_id ;
    if sql%rowcount = 0
    then
        fnd_message.set_name('IGS','IGS_SS_ENR_CART_NO_DELETE');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
    end if ;
    exception
    when others
    then
        fnd_message.set_name('IGS','IGS_SS_WHEN_OTHERS');
        fnd_msg_pub.add;
        p_return_status :=  fnd_api.g_ret_sts_error;
    end ;
end delete_from_su_attempt;


FUNCTION get_Sch_disp_acad(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN VARCHAR2 AS
 ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose:This Function returns the concatendated current academic calendar
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  l_acad_year_flag igs_en_ss_disp_stps.academic_year_flag%TYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  l_message                     VARCHAR2(300);
BEGIN

    --  Get the superior academic calendar instance
    Igs_En_Gen_015.get_academic_cal
    (
     p_person_id               => p_person_id,
     p_course_cd               => p_program_cd,
     p_acad_cal_type           => l_acad_cal_type,
     p_acad_ci_sequence_number => l_acad_ci_sequence_number,
     p_message                 => l_message,
     p_effective_dt            => SYSDATE
    );

    RETURN l_acad_ci_sequence_number||l_acad_cal_type;

EXCEPTION
  WHEN OTHERS THEN
    -- supress any error message raised as this function is used in query
    RETURN NULL;

END get_Sch_disp_acad;

FUNCTION get_Sch_disp_term(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN VARCHAR2 AS
 ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose:This Function returns the concatendated current Term calendar related to the current academic calendar
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get the Schedule display indicator
  CURSOR c_sch_disp IS
  SELECT academic_year_flag
  FROM igs_en_ss_disp_stps;

  -- Get the first Term calendar
  CURSOR c_first_term_acad(cp_acad_cal_type VARCHAR2,cp_acad_ci_sequence_number NUMBER) IS
  SELECT ci.sequence_number||ci.cal_type
  FROM igs_ca_inst ci,
       igs_ca_inst_rel cir,
       igs_ca_type ct,
       igs_ca_stat cs
  WHERE ci.cal_type = cir.sub_cal_type AND
        ci.sequence_number = cir.sub_ci_sequence_number AND
        ci.cal_type = ct.cal_type AND
        ct.s_cal_cat = 'LOAD' AND
        ci.cal_status = cs.cal_status AND
        cs.s_cal_status = 'ACTIVE' AND
        cir.sup_cal_type = cp_acad_cal_type AND
        cir.sup_ci_sequence_number = cp_acad_ci_sequence_number
  ORDER BY ci.start_dt;

  -- Get the academic calendar
   CURSOR c_acad_cal(cp_person_id NUMBER, cp_program_cd VARCHAR2) IS
   SELECT cal_type
   FROM igs_en_stdnt_ps_att
   WHERE person_id = cp_person_id AND
         course_cd = cp_program_cd;

  l_acad_year_flag igs_en_ss_disp_stps.academic_year_flag%TYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  l_message                     VARCHAR2(300);
  l_term_calendar VARCHAR2(30);
  l_schedule_disp igs_en_ss_disp_stps.academic_year_flag%TYPE;
  l_load_cal_type   igs_ca_inst.cal_type%TYPE;
  l_load_ci_seq_num   igs_ca_inst.sequence_number%TYPE;
  l_load_ci_alt_code igs_ca_inst.alternate_code%TYPE ;
  l_load_ci_start_dt igs_ca_inst.start_dt%TYPE ;
  l_load_ci_end_dt igs_ca_inst.end_dt%TYPE ;

BEGIN

  l_schedule_disp := 'N';

  OPEN c_sch_disp;
  FETCH c_sch_disp INTO l_schedule_disp;
  CLOSE c_sch_disp;

  IF l_schedule_disp = 'Y' THEN
    --  Get the superior academic calendar instance
    Igs_En_Gen_015.get_academic_cal
    (
     p_person_id               => p_person_id,
     p_course_cd               => p_program_cd,
     p_acad_cal_type           => l_acad_cal_type,
     p_acad_ci_sequence_number => l_acad_ci_sequence_number,
     p_message                 => l_message,
     p_effective_dt            => SYSDATE
    );

    -- Get the first term calendar associated with the academic calendar
    OPEN c_first_term_acad(l_acad_cal_type,l_acad_ci_sequence_number);
    FETCH c_first_term_acad INTO l_term_calendar;
    CLOSE c_first_term_acad;
  ELSE

    OPEN c_acad_cal(p_person_id, p_program_cd);
    FETCH c_acad_cal INTO l_acad_cal_type;
    CLOSE c_acad_cal;

    igs_en_gen_015.get_curr_acad_term_cal (
       p_acad_cal_type     =>   l_acad_cal_type,
       p_effective_dt      =>   SYSDATE,
       p_load_cal_type     =>   l_load_cal_type,
       p_load_ci_seq_num   =>   l_load_ci_seq_num,
       p_load_ci_alt_code  =>   l_load_ci_alt_code,
       p_load_ci_start_dt  =>   l_load_ci_start_dt,
       p_load_ci_end_dt    =>   l_load_ci_end_dt,
       p_message_name      =>   l_message);

     l_term_calendar := l_load_ci_seq_num||l_load_cal_type;
  END IF;

  RETURN l_term_calendar;
EXCEPTION
  WHEN OTHERS THEN
    -- supress any error message raised as this function is used in query
    RETURN NULL;

END get_Sch_disp_term;

FUNCTION get_Sch_disp_term_st_dt(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN DATE AS
 ------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created: 03-NOV-2003
  --
  --Purpose:This Function returns the start date of the current Term calendar.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --rvangala  16-JUL-2004     Changed call to igs_en_gen_015.get_curr_acad_term_cal
  --                          with igs_en_gen_015.get_curr_term_for_schedule
  -------------------------------------------------------------------

  -- Get the Schedule display indicator
  CURSOR c_sch_disp IS
  SELECT academic_year_flag
  FROM igs_en_ss_disp_stps;

  -- Get the first Term calendar
  CURSOR c_first_term_acad(cp_acad_cal_type VARCHAR2,cp_acad_ci_sequence_number NUMBER) IS
  SELECT ci.start_dt
  FROM igs_ca_inst ci,
       igs_ca_inst_rel cir,
       igs_ca_type ct,
       igs_ca_stat cs
  WHERE ci.cal_type = cir.sub_cal_type AND
        ci.sequence_number = cir.sub_ci_sequence_number AND
        ci.cal_type = ct.cal_type AND
        ct.s_cal_cat = 'LOAD' AND
        ci.cal_status = cs.cal_status AND
        cs.s_cal_status = 'ACTIVE' AND
        cir.sup_cal_type = cp_acad_cal_type AND
        cir.sup_ci_sequence_number = cp_acad_ci_sequence_number
  ORDER BY ci.start_dt;

  -- Get the academic calendar
   CURSOR c_acad_cal(cp_person_id NUMBER, cp_program_cd VARCHAR2) IS
   SELECT cal_type
   FROM igs_en_stdnt_ps_att
   WHERE person_id = cp_person_id AND
         course_cd = cp_program_cd;

  l_acad_year_flag igs_en_ss_disp_stps.academic_year_flag%TYPE;
  l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
  l_message                     VARCHAR2(300);
  l_schedule_disp igs_en_ss_disp_stps.academic_year_flag%TYPE;
  l_term_start_dt DATE ;

  l_load_cal_type   igs_ca_inst.cal_type%TYPE;
  l_load_ci_seq_num   igs_ca_inst.sequence_number%TYPE;
  l_load_ci_alt_code igs_ca_inst.alternate_code%TYPE ;
  l_load_ci_start_dt igs_ca_inst.start_dt%TYPE ;
  l_load_ci_end_dt igs_ca_inst.end_dt%TYPE ;

BEGIN
  l_term_start_dt := SYSDATE;
  l_schedule_disp := 'N';

  OPEN c_sch_disp;
  FETCH c_sch_disp INTO l_schedule_disp;
  CLOSE c_sch_disp;

  IF l_schedule_disp = 'Y' THEN
    --  Get the superior academic calendar instance
    Igs_En_Gen_015.get_academic_cal
    (
     p_person_id               => p_person_id,
     p_course_cd               => p_program_cd,
     p_acad_cal_type           => l_acad_cal_type,
     p_acad_ci_sequence_number => l_acad_ci_sequence_number,
     p_message                 => l_message,
     p_effective_dt            => SYSDATE
    );

    -- Get the first term calendar associated with the academic calendar
    OPEN c_first_term_acad(l_acad_cal_type,l_acad_ci_sequence_number);
    FETCH c_first_term_acad INTO l_term_start_dt;
    CLOSE c_first_term_acad;
  ELSE

    OPEN c_acad_cal(p_person_id, p_program_cd);
    FETCH c_acad_cal INTO l_acad_cal_type;
    CLOSE c_acad_cal;

    igs_en_gen_015.get_curr_term_for_schedule (
       p_acad_cal_type     =>   l_acad_cal_type,
       p_effective_dt      =>   SYSDATE,
       p_load_cal_type     =>   l_load_cal_type,
       p_load_ci_seq_num   =>   l_load_ci_seq_num,
       p_load_ci_alt_code  =>   l_load_ci_alt_code,
       p_load_ci_start_dt  =>   l_load_ci_start_dt,
       p_load_ci_end_dt    =>   l_load_ci_end_dt,
       p_message_name      =>   l_message);

     l_term_start_dt := l_load_ci_start_dt;
  END IF;
  RETURN l_term_start_dt;

EXCEPTION
  WHEN OTHERS THEN
    -- supress any error message raised as this function is used in query
    RETURN NULL;

END get_Sch_disp_term_st_dt;


FUNCTION enrf_get_lookup_meaning(
  p_lookup_code IN VARCHAR2,
  p_lookup_type IN VARCHAR2)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:This Function returns the lookup code meaning.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_get_meaning IS
  SELECT meaning
  FROM   igs_lookup_values
  WHERE  lookup_code = p_lookup_code
  AND    lookup_type = p_lookup_type;
  l_c_meaning  igs_lookup_values.meaning%TYPE;

BEGIN
  OPEN cur_get_meaning;
  FETCH cur_get_meaning INTO l_c_meaning;
  CLOSE cur_get_meaning;
  RETURN l_c_meaning;
END enrf_get_lookup_meaning;

FUNCTION enrf_get_sca_trans_ind(
  p_person_id IN NUMBER ,
  p_source_program_cd IN VARCHAR2,
  p_dest_program_cd IN VARCHAR2)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following function is used to determine if the destination program attempt has been selected and program transfer
  --        submitted once. This is being determined by the presence of the program attempt transfer record in the table IGS_PS_STDNT_TRN
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_prg_trns IS
  SELECT 'X'
  FROM  igs_ps_stdnt_trn
  WHERE course_cd= p_dest_program_cd
  AND   transfer_course_cd = p_source_program_cd
  AND   person_id = p_person_id;
  l_c_var  VARCHAR2(1);

BEGIN
  OPEN cur_prg_trns;
  FETCH cur_prg_trns INTO l_c_var;
  IF cur_prg_trns%FOUND THEN
    CLOSE cur_prg_trns;
    RETURN 'SCA-Y';
  ELSE
    CLOSE cur_prg_trns;
    RETURN 'SCA-N';
  END IF;
END enrf_get_sca_trans_ind;

FUNCTION enrf_get_sua_trans_ind(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_uoo_id IN NUMBER )
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following function is used to determine if a unit section in the source program has been transfer to the destination
  --        program attempt. This is done, by checking the existance of the program attempt record, since the transfer record is not created for all unit attempt status.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_usec_trns IS
  SELECT 'X'
  FROM   igs_en_su_attempt
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd
  AND    uoo_id    = p_uoo_id
  AND unit_Attempt_status <> 'DROPPED';
  l_c_var  VARCHAR2(1);
BEGIN
  OPEN cur_usec_trns;
  FETCH cur_usec_trns INTO l_c_var;
  IF cur_usec_trns%FOUND THEN
    CLOSE cur_usec_trns;
    RETURN 'SUA-Y';
  ELSE
    CLOSE cur_usec_trns;
    RETURN 'SUA-N';
  END IF;
END enrf_get_sua_trans_ind;

FUNCTION enrf_get_susa_trans_ind(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_unit_set_cd IN VARCHAR2,
  p_us_version_number IN NUMBER)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following function is used to return the value, which specifies in the unit set attempt has been transferred, or not.
  --        This is determined based on the existence of the same unit set attempt (that is present in the source program) against the destination program attempt
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_unitset_trns IS
  SELECT 'X'
  FROM   igs_as_su_setatmpt
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd
  AND    unit_set_cd = p_unit_set_cd
  AND    us_version_number = p_us_version_number;
  l_c_var  VARCHAR2(1);
BEGIN
  OPEN cur_unitset_trns;
  FETCH cur_unitset_trns INTO l_c_var;
  IF cur_unitset_trns%FOUND THEN
    CLOSE cur_unitset_trns;
    RETURN 'SUSA-Y';
  ELSE
    CLOSE cur_unitset_trns;
    RETURN 'SUSA-N';
  END IF;
END enrf_get_susa_trans_ind;

FUNCTION get_dup_sua_src_prog(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:Procedure to get the source unit attempt for the duplicate unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_src_unit_atmpt IS
  SELECT sut.transfer_course_cd
  FROM   igs_ps_stdnt_unt_trn  sut,
         igs_en_su_attempt sua
  WHERE  sut.person_id = p_person_id
  AND    sua.person_id = sut.person_id
  AND    sut.uoo_id = p_uoo_id
  AND    sua.uoo_id = sut.uoo_id
  AND    sua.course_cd = sut.transfer_course_cd
  AND    sut.course_cd = p_course_cd
  ORDER BY sut.transfer_dt desc;
  l_c_transfer_course_cd  igs_ps_stdnt_unt_trn.transfer_course_cd%TYPE;

BEGIN
  OPEN   cur_src_unit_atmpt;
  FETCH  cur_src_unit_atmpt INTO l_c_transfer_course_cd;
  CLOSE  cur_src_unit_atmpt;
  RETURN l_c_transfer_course_cd;
END get_dup_sua_src_prog;


FUNCTION enrf_get_mark_grade(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_unit_attempt_Status IN VARCHAR2)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following procedure is used to retrieve the marks and grades for a particular unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  l_c_result_type        VARCHAR2(1000);
  l_d_outcome_dt         DATE;
  l_c_grading_schema_cd  VARCHAR2(30);
  l_n_gs_version_number  NUMBER;
  l_c_grade              VARCHAR2(100);
  l_n_mark               NUMBER;
  l_c_origin_course_cd   VARCHAR2(30);
BEGIN
  l_c_result_type := igs_as_gen_003.assp_get_sua_outcome(
     p_person_id,
     p_course_cd,
     NULL,
     NULL,
     NULL,
     p_unit_attempt_Status,
     'Y', -- require finalised result
     l_d_outcome_dt,
     l_c_grading_schema_cd,
     l_n_gs_version_number,
     l_c_grade,
     l_n_mark,
     l_c_origin_course_cd,
     p_uoo_id,
     'N');

  RETURN NVL(TO_CHAR(l_n_mark), l_c_grade);

END enrf_get_mark_grade;

FUNCTION enrf_get_cal_desc(
  p_cal_type IN VARCHAR2,
  p_sequence_number IN NUMBER)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following function is used to determine the calendar description based on the calendar type and sequence number
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_cal_desc IS
  SELECT description
  FROM   igs_ca_inst
  WHERE  cal_type = p_cal_type
  AND    sequence_number = p_sequence_number;
  l_c_description igs_ca_inst.description%TYPE;
BEGIN
  OPEN cur_cal_desc;
  FETCH cur_cal_desc INTO l_c_description;
  CLOSE cur_cal_desc;

  RETURN l_c_description;

END enrf_get_cal_desc;

FUNCTION enrf_get_acad_cal_desc(
  p_teach_cal_type IN VARCHAR2,
  p_teach_seqeunce_number IN NUMBER)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following function is used to determine the acadaemic calendar's description based on a teaching calendar instance.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  l_c_result                   VARCHAR2(1000);
  l_c_acad_cal_type            igs_ca_inst.cal_type%TYPE;
  l_n_acad_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
  l_d_acad_ci_start_dt         DATE;
  l_d_acad_ci_end_dt           DATE;
  l_c_message_name             fnd_new_messages.message_name%TYPE;
BEGIN
  l_c_result := igs_en_gen_002.enrp_get_acad_alt_cd(
                   p_teach_cal_type,
		   p_teach_seqeunce_number,
		   l_c_acad_cal_type,
		   l_n_acad_ci_sequence_number,
		   l_d_acad_ci_start_dt,
		   l_d_acad_ci_end_dt,
		   l_c_message_name);


  RETURN enrf_get_cal_desc(l_c_acad_cal_type, l_n_acad_ci_sequence_number);

END enrf_get_acad_cal_desc;

FUNCTION enrp_get_career_drop_dup(
  p_person_id in NUMBER ,
  p_program_cd in VARCHAR2,
  p_uoo_id in NUMBER)
  RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle IDC
  --Date created: 09-NOV-2004
  --
  --Purpose:The following fucntion is used to determine if a particular duplicate unit attempt can be dropped or not
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  -------------------------------------------------------------------
  CURSOR cur_src_prg IS
  SELECT transfer_course_cd
  FROM   igs_ps_stdnt_unt_trn
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd
  AND    uoo_id    = p_uoo_id;
  l_c_transfer_course_cd igs_ps_stdnt_unt_trn.transfer_course_cd%TYPE;

  CURSOR cur_prg_atmpt(cp_program_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
  SELECT course_type
  FROM   igs_en_stdnt_ps_att sca,
         igs_ps_ver cv
  WHERE  sca.person_id = p_person_id
  AND    sca.course_cd = cp_program_cd
  AND    cv.course_cd  = sca.course_cd
  AND    cv.version_number = sca.version_number;
  l_c_src_course_type   igs_ps_ver.course_type%TYPE;
  l_c_dest_course_type  igs_ps_ver.course_type%TYPE;

BEGIN
  IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') = 'N' THEN
    RETURN 'Y';
  END IF;

  -- select the source program based on the passed in parameters
  OPEN cur_src_prg;
  FETCH cur_src_prg INTO l_c_transfer_course_cd;
  CLOSE cur_src_prg;

  -- select the career/course type for the source program attempt
  OPEN cur_prg_atmpt(l_c_transfer_course_cd);
  FETCH cur_prg_atmpt INTO l_c_src_course_type;
  CLOSE cur_prg_atmpt;

  -- select the career/course type for the destination program attempt
  OPEN cur_prg_atmpt(p_program_cd);
  FETCH cur_prg_atmpt INTO l_c_dest_course_type;
  CLOSE cur_prg_atmpt;

  --In career-centric mode, for transfers across careers, users can drop a
  --duplicate in the destination program from the schedule.
  -- if the source and destination programs belong to different careers then return 'Y'
  IF l_c_src_course_type <> l_c_dest_course_type THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

  RETURN 'Y';

END enrp_get_career_drop_dup;

end igs_ss_enroll_pkg ;

/
