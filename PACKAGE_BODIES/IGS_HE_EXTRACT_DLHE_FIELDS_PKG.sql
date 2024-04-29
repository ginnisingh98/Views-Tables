--------------------------------------------------------
--  DDL for Package Body IGS_HE_EXTRACT_DLHE_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EXTRACT_DLHE_FIELDS_PKG" AS
/* $Header: IGSHE9DB.pls 120.1 2006/02/13 17:25:48 jbaber noship $ */


   PROCEDURE write_to_log(p_message    IN VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedures writes onto the log file
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/
   BEGIN

      Fnd_File.Put_Line(Fnd_File.Log, p_message);

   END write_to_log;


   PROCEDURE get_survey_method
          (p_dlhe_method          IN igs_he_stdnt_dlhe.survey_method%TYPE,
           p_hesa_method          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Method of data collection
                                mapped to dlhe record's survey method
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      l_he_code_map_val.association_code := 'OSS_HESA_METHOD_ASSOC';
      l_he_code_map_val.map2             := p_dlhe_method;

      IF p_dlhe_method IS NOT NULL
      THEN
          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_method);

      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_survey_method');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_survey_method;


   PROCEDURE get_empcir
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_employment      IN  igs_he_stdnt_dlhe.Employment%TYPE,
           p_hesa_empcir          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Employment circumstances mapped
                            to the dlhe record's employement
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 8 or 9 or employment value not found then return Default value.
      IF  p_hesa_method IN ('8','9') OR p_dlhe_employment IS NULL THEN
          -- default value processing
          p_hesa_empcir := 'XX' ;
      ELSIF p_dlhe_employment IS NOT NULL THEN
          -- Get the hesa code mapped to the dlhe record's employement field
	  l_he_code_map_val.association_code := 'OSS_HESA_EMPCIR_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_employment;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_empcir);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_empcir');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_empcir;


   PROCEDURE get_mode_study
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_further_study   IN  igs_he_stdnt_dlhe.Further_study%TYPE,
           p_hesa_modstudy        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Mode of Study
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      -- if method is 8 or 9 or Further study value not found then return Default value.
      IF  p_hesa_method IN ('8','9') OR p_dlhe_further_study IS NULL THEN
          -- default value processing
          p_hesa_modstudy := 'X' ;
      ELSIF p_dlhe_further_study IS NOT NULL THEN
          -- get the hesa code mapped to the dlhe record's further study field
	  l_he_code_map_val.association_code := 'OSS_HESA_MODSTUDY_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_further_study;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_modstudy);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_mode_study');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_mode_study;


   PROCEDURE get_makedo
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_business    IN  igs_he_stdnt_dlhe.Employer_business%TYPE,
           p_hesa_makedo          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Nature of employers business
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )) AND
           p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
	   -- default value processing
          p_hesa_makedo := 'XXXX' ;
      ELSIF p_dlhe_Emp_business IS NOT NULL THEN
          -- return value of employer_business if present else return default value
          p_hesa_makedo := p_dlhe_Emp_business ;
      ELSIF p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
          p_hesa_makedo := 'XXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_makedo');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_makedo;


   PROCEDURE get_sic
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_class       IN  igs_he_stdnt_dlhe.Employer_classification%TYPE,
           p_hesa_sic             OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA employers business classification
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )) AND
           p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
	   -- default value processing
          p_hesa_sic := 'XXXX' ;
      ELSIF p_dlhe_Emp_class IS NOT NULL THEN
          -- if employement classfication is given then return hesa code mapped to that else return default value
	  l_he_code_map_val.association_code := 'OSS_HESA_SIC_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_Emp_class;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_sic);

      ELSIF p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
          p_hesa_sic := 'XXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_sic');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_sic;


   PROCEDURE get_emp_loc
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Emp_postcode    IN  igs_he_stdnt_dlhe.Employer_postcode%TYPE,
	   p_dlhe_emp_country     IN  igs_he_stdnt_dlhe.Employer_country%TYPE,
           p_hesa_locemp          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Location of employment
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )) AND
           p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
	   -- default value processing
          p_hesa_locemp := 'XXXXXXXX' ;
      ELSIF p_dlhe_Emp_postcode IS NOT NULL THEN
          -- if employer postcode is given then return that
          p_hesa_locemp := p_dlhe_Emp_postcode ;
      ELSIF p_dlhe_emp_country IS NOT NULL THEN
          -- if employer countrycode is given then return that else return default value
          p_hesa_locemp := p_dlhe_emp_country ;
      ELSIF p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
          p_hesa_locemp := 'XXXXXXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_emp_loc');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_emp_loc;



   PROCEDURE get_job_title
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_jobtitle	  IN  igs_he_stdnt_dlhe.Job_title%TYPE,
           p_hesa_jobtitle        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Job title
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' ) )  AND
            p_hesa_empcir NOT IN ('01','02','03','04','05') THEN
	   -- default value processing
	   p_hesa_jobtitle := 'XXXX' ;
      ELSIF p_dlhe_jobtitle IS NOT NULL THEN
           -- if dlhe job title is given then return that else return default value
            p_hesa_jobtitle := p_dlhe_jobtitle;
      ELSIF p_hesa_empcir NOT IN ('01','02','03','04','05') THEN
	   p_hesa_jobtitle := 'XXXX' ;
      END IF;

  EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_job_title');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_job_title;


   PROCEDURE get_occ_class
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_job_class       IN  igs_he_stdnt_dlhe.Job_classification%TYPE,
           p_hesa_soc             OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Standard Occupational Classification
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )) AND
             p_hesa_empcir NOT IN ('01','02','03','04','05') THEN
	  -- default value processing
          p_hesa_soc := 'XXXXX' ;
      ELSIF p_dlhe_job_class IS NOT NULL THEN
          -- if dlhe jo classification is given then return its hesa mapped code else return default value
	  l_he_code_map_val.association_code := 'OSS_HESA_SOCDLHE_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_job_class;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_soc);

      ELSIF p_hesa_empcir NOT IN ('01','02','03','04','05')  THEN
          p_hesa_soc := 'XXXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_occ_class');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_occ_class;



   PROCEDURE get_emp_size
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_size        IN  igs_he_stdnt_dlhe.Employer_size%TYPE,
           p_hesa_empsize         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              : This procedure gets the HESA Employer size
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      -- if method is 8 or 9 or empcir between 06 to 14 or if employer_size is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
            OR p_dlhe_emp_size IS NULL
	  ) THEN
          -- default value processing
	   p_hesa_empsize := 'X' ;
      ELSIF p_dlhe_emp_size IS NOT NULL THEN
          -- return the hesa code mapped to dlhe employement size
	  l_he_code_map_val.association_code := 'OSS_HESA_EMPSIZE_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_emp_size;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_empsize);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_emp_size');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_emp_size;


   PROCEDURE get_emp_duration
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_duration    IN  igs_he_stdnt_dlhe.Job_duration%TYPE,
           p_hesa_duration        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Duration of employment
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      -- if method is 9 or empcir between 06 to 14 or if job_duration is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
             OR  p_dlhe_emp_duration IS NULL
	  ) THEN
           -- default value processing
	   p_hesa_duration := 'X' ;
      ELSIF p_dlhe_emp_duration IS NOT NULL THEN
          -- return the hesa code mapped to dlhe job duration
	  l_he_code_map_val.association_code := 'OSS_HESA_DURATION_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_emp_duration;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_duration);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_emp_duration');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_emp_duration;


   PROCEDURE get_salary
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_Job_salary      IN  igs_he_stdnt_dlhe.Job_salary%TYPE,
           p_hesa_salary          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Salary
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )) THEN
          -- default value processing
          p_hesa_salary := 'XXXXXX' ;
      ELSIF p_dlhe_Job_salary IS NOT NULL THEN
          -- if dlhe salary is given then return that else return the default value
          p_hesa_salary := p_dlhe_Job_salary ;
      ELSE
          p_hesa_salary := 'XXXXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_salary');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_salary;



   PROCEDURE get_qual_req
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_qual_req        IN  igs_he_stdnt_dlhe.Qualification_requirement%TYPE,
           p_hesa_qualreq         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Qualification required for job
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

	-- if method is 9 or empcir between 06 to 14 or if qual_requirement is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
            OR  p_dlhe_qual_req IS NULL
	  ) THEN
           -- default value processing
	   p_hesa_qualreq := 'X' ;
      ELSIF p_dlhe_qual_req IS NOT NULL THEN
          -- return the hesa code mapped to dlhe qualification requirement
	  l_he_code_map_val.association_code := 'OSS_HESA_QUALREQ_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_qual_req;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_qualreq);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_qual_req');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_qual_req;


   PROCEDURE get_emp_imp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_emp_imp         IN  igs_he_stdnt_dlhe.Qualification_importance%TYPE,
           p_hesa_empimp          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Qualification is important for job
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      -- if method is 9 or empcir between 06 to 14 or if qual_importance is null then return default
      IF  ( p_hesa_method IN ('3','4','8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
            OR  p_dlhe_emp_imp IS NULL
	  ) THEN
         -- default value processing
	   p_hesa_empimp := 'X' ;
      ELSIF p_dlhe_emp_imp IS NOT NULL THEN
          -- return the hesa code mapped to dlhe qualification importance
	  l_he_code_map_val.association_code := 'OSS_HESA_EMPIMP_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_emp_imp;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_empimp);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_emp_imp');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_emp_imp;


   PROCEDURE get_career
          (p_hesa_reason       IN  igs_he_stdnt_dlhe.Job_reason1%TYPE,
           p_hesa_career       OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Career related code 1 to 8
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
        -- if job reason 1 to 8 is Y then return 1 else return 0
	IF p_hesa_reason ='Y' THEN
	        p_hesa_career := '1'  ;
        ELSE
	        p_hesa_career := '0';
	END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_career');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_career;


   PROCEDURE get_job_find
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_job_source      IN  igs_he_stdnt_dlhe.Job_source%TYPE,
           p_hesa_jobfnd          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA How found job
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 8 or 9 or empcir between 06 to 14 or if Job_source is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
            OR p_dlhe_job_source IS NULL
	  ) THEN
          -- default value processing
	   p_hesa_jobfnd := 'X' ;
      ELSIF p_dlhe_job_source IS NOT NULL THEN
          -- return the hesa code mapped to dlhe job_source
	  l_he_code_map_val.association_code := 'OSS_HESA_JOBFND_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_job_source;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_jobfnd);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_job_find');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_job_find;


   PROCEDURE get_prev_emp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_previous_job    IN  igs_he_stdnt_dlhe.Previous_job%TYPE,
           p_hesa_prevemp         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Previously employed
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 8 or 9 or empcir between 06 to 14 or if Previous_job is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
            OR p_dlhe_previous_job IS NULL
	  ) THEN
          -- default value processing
	   p_hesa_prevemp := 'X' ;
      ELSIF p_dlhe_previous_job IS NOT NULL THEN
          -- return the hesa code mapped to dlhe previous job
	  l_he_code_map_val.association_code := 'OSS_HESA_PREVEMP_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_previous_job;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_prevemp);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_prev_emp');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_prev_emp;


   PROCEDURE get_prev_emp_cat
          (p_hesa_method              IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcir              IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_prevemp             IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_previous_jobtype    IN  igs_he_stdnt_dlhe.Previous_jobtype1%TYPE,
           p_hesa_prevcat             OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA  Category of previous employment 1 to 6
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
        IF  ( p_hesa_method IN ('8','9') OR p_hesa_empcir IN ('06','07','08','09','10','11','12','13','14','XX' )
	        OR p_hesa_prevemp = '4' )  THEN
	   -- default value processing
	   p_hesa_prevcat := 'X' ;
	ELSIF p_dlhe_previous_jobtype = 'Y' THEN
	   -- if previous jobtype 1 to 6  ='Y then return 1 else return 0
	        p_hesa_prevcat := '1'  ;
        ELSE
	        p_hesa_prevcat := '0';
	END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_prev_emp_cat');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_prev_emp_cat;


   PROCEDURE get_nat_study
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_type      IN  igs_he_stdnt_dlhe.Further_study_type%TYPE,
           p_hesa_natstudy        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Nature of study/training
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN

      -- if method is 8 or 9 or empcir between 06 to 14 or if Further_study_type is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_modstudy IN ('3','X' ) OR p_dlhe_study_type IS NULL
	  ) THEN
           -- default value processing
	   p_hesa_natstudy := 'X' ;
      ELSIF p_dlhe_study_type IS NOT NULL THEN
          -- return hesa code mapped to dlhe further study type
	  l_he_code_map_val.association_code := 'OSS_HESA_NATSTUDY_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_study_type;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_natstudy);
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_nat_study');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_nat_study;


   PROCEDURE get_train_subj
          (p_hesa_method             IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy           IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_natstudy           IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_crse_train_subj    IN  igs_he_stdnt_dlhe.Course_training_subject%TYPE,
	   p_dlhe_res_train_subj     IN  igs_he_stdnt_dlhe.Research_training_subject%TYPE,
           p_hesa_profsoct           OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure gets the HESA Professional subject of training
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_modstudy IN ('3','X' ) OR p_hesa_natstudy IN ('3','4') )  THEN
          -- default value processing
          p_hesa_profsoct := 'XXXXX' ;
      ELSIF p_dlhe_crse_train_subj IS NOT NULL THEN
          -- if course training subject is given then return its hesa code
	  l_he_code_map_val.association_code := 'OSS_HESA_SOCDLHE_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_crse_train_subj;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_profsoct);

      ELSIF p_dlhe_res_train_subj IS NOT NULL THEN
          -- if research training subject is given then return its hesa code else return default value
	  l_he_code_map_val.association_code := 'OSS_HESA_SOCDLHE_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_res_train_subj;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_profsoct);

      ELSE
          p_hesa_profsoct := 'XXXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_train_subj');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_train_subj;


   PROCEDURE get_inst_prov
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_natstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_prov      IN  igs_he_stdnt_dlhe.Further_study_provider%TYPE,
           p_hesa_instprov        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Institution providing study
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('3','4','8','9') OR p_hesa_modstudy IN ('3','X' ) OR p_hesa_natstudy IN ('3','4') )  THEN
         -- default value processing
          p_hesa_instprov := 'XXXX' ;
      ELSIF p_dlhe_study_prov IS NOT NULL THEN
          -- return dlhe further study provide if given else return default value
          p_hesa_instprov := p_dlhe_study_prov ;
      ELSE
          p_hesa_instprov := 'XXXX' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_inst_prov');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_inst_prov;


   PROCEDURE get_type_qual
          (p_hesa_method            IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_qualaim     IN  igs_he_stdnt_dlhe.Further_study_qualaim%TYPE,
           p_hesa_typequal          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Type of qualification
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
   smaddali   23-sep-03   Removed parameter p_hesa_natstudy for build HECR011 , bug#3051597
  ***************************************************************/
     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 9 or mode study is 3 or if Further_study_qualaim is null then return default
      IF  ( p_hesa_method IN ('8','9') OR p_hesa_modstudy IN ('3','X' )
            OR  p_dlhe_study_qualaim IS NULL
	  ) THEN
           -- default value processing
          p_hesa_typequal := 'XX' ;
      ELSIF p_dlhe_study_qualaim IS NOT NULL THEN
          -- return the hesa code mapped to dlhe study qualification aim
	  l_he_code_map_val.association_code := 'OSS_HESA_TYPEQUAL_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_study_qualaim;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_typequal);
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_type_qual');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_type_qual;


   PROCEDURE get_study_reason2
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy        IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_study_reason    IN  igs_he_stdnt_dlhe.Study_reason2%TYPE,
           p_hesa_secint          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Reason for taking another course 2 to 7
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When          What
   smaddali             23-sep-03     Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('3','4','8','9') OR p_hesa_modstudy IN ('3','X' )  )  THEN
	  -- default value processing
          p_hesa_secint := 'X' ;
      ELSIF p_dlhe_study_reason = 'Y' THEN
          -- if reason for study 2 to 7 is Y then return 1 else return 0
          p_hesa_secint := '1' ;
      ELSE
          p_hesa_secint := '0';
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_study_reason2');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_study_reason2;


   PROCEDURE get_study_reason8
          (p_hesa_method             IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy           IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_other_study_reason IN igs_he_stdnt_dlhe.Other_study_reason%TYPE,
	   p_dlhe_no_study_reason    IN  igs_he_stdnt_dlhe.No_other_study_reason%TYPE,
           p_hesa_secint8            OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA Reason for taking another course 8
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali             23-sep-03     Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('3','4','8','9') OR p_hesa_modstudy IN ('3','X' )  )  THEN
	  -- default value processing
          p_hesa_secint8 := 'X' ;
      ELSIF p_dlhe_other_study_reason IS NOT NULL THEN
          -- if other reason for study given then return 1
          p_hesa_secint8 := '1' ;
      ELSIF p_dlhe_no_study_reason = 'Y' THEN
          -- if no other reason for study is given then return 0 else return default value
          p_hesa_secint8 := '0';
      ELSE
          p_hesa_secint8 := 'X' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_study_reason8');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_study_reason8;


   PROCEDURE get_funding_source
          (p_hesa_method            IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_modstudy          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_funding_source    IN  igs_he_stdnt_dlhe.Funding_source%TYPE,
           p_hesa_fundstudy         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              : This procedure gets the HESA  funding further study
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When          What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
   smaddali             23-sep-03     Removed parameter p_hesa_natstudy, p_hesa_emppaid for build HECR011 , bug#3051597
  ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 9 or modestudy is 3 or nature of study is 3,4 or if Funding_source is null then return default
      IF  ( p_hesa_method IN ('8','9')  OR p_hesa_modstudy IN ('3','X' ) OR
	        p_dlhe_funding_source IS NULL
	  )  THEN
	  -- default value processing
          p_hesa_fundstudy := 'X' ;
      ELSIF p_dlhe_funding_source IS NOT NULL THEN
          -- return the hesa code mapped to dlhe funding source
	  l_he_code_map_val.association_code := 'OSS_HESA_FUNDSTDY_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_funding_source;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_fundstudy);
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_funding_source');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_funding_source;


   PROCEDURE get_teaching_emp
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_qualified       IN  igs_he_stdnt_dlhe.Qualified_teacher%TYPE,
           p_dlhe_teaching        IN  igs_he_stdnt_dlhe.Teacher_teaching%TYPE ,
           p_dlhe_seeking         IN  igs_he_stdnt_dlhe.Teacher_seeking%TYPE ,
           p_hesa_tchemp          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              : This procedure gets the HESA Teaching employment marker
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  p_hesa_method IN ('8','9') THEN
          -- default value processing
          p_hesa_tchemp := 'X' ;
      ELSIF p_dlhe_qualified ='N' THEN
          -- if not a qualified teacher then return 9
          p_hesa_tchemp := '9' ;
      ELSIF p_dlhe_teaching ='Y' THEN
          -- if a qualified teacher and is teaching then return 3
          p_hesa_tchemp := '3' ;
      ELSIF p_dlhe_seeking = 'Y'  THEN
          -- if a qualified teacher seeking teaching post then return 1
          p_hesa_tchemp := '1' ;
      ELSIF p_dlhe_teaching ='N' AND p_dlhe_seeking = 'N'  THEN
          -- if a qualified teacher not working or seeking job then return 2
          p_hesa_tchemp := '2' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teaching_emp');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_teaching_emp;



   PROCEDURE get_teaching_sector
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_tchemp          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_teach_sector    IN  igs_he_stdnt_dlhe.Teaching_sector%TYPE,
           p_hesa_teachsct        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              : This procedure gets the HESA  Teaching sector
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 9 or teaching employement in 1,2,9 or if Teaching_sector is null then return default
      IF  ( p_hesa_method IN ('8','9')  OR p_hesa_tchemp IN ('1','2','9','X' ) OR  p_dlhe_teach_sector IS NULL
	  )  THEN
          -- default value processing
          p_hesa_teachsct := 'X' ;
      ELSIF p_dlhe_teach_sector IS NOT NULL THEN
          -- return the hesa code mapped to the dlhe teaching sector
	  l_he_code_map_val.association_code := 'OSS_HESA_TEACHSCT_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_teach_sector;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_teachsct);
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teaching_sector');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_teaching_sector;


   PROCEDURE get_teaching_phase
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_tchemp          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_teach_level     IN  igs_he_stdnt_dlhe.Teaching_level%TYPE,
           p_hesa_teachphs        OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA  Teaching Phase
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 9 or teaching employement in 1,2,9 or if Teaching_level is null then return default
      IF  ( p_hesa_method IN ('8','9')  OR p_hesa_tchemp IN ('1','2','9','X' )
            OR p_dlhe_teach_level IS NULL
	  )  THEN
         -- default value processing
          p_hesa_teachphs := 'X' ;
      ELSIF p_dlhe_teach_level IS NOT NULL THEN
          -- return the hesa code mapped to dlhe teaching level
	  l_he_code_map_val.association_code := 'OSS_HESA_TEACHPHS_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_teach_level;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_teachphs);
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_teaching_phase');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_teaching_phase;


   PROCEDURE get_intent
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study        IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_reason_ptcrse   IN  igs_he_stdnt_dlhe.Reason_for_PTcourse%TYPE,
           p_hesa_intent          OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA  Reason for taking original course
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali            04-jul-03      modified default processing for bug#3036995 to add one more condition
  ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      -- if method is 9 or PT_Study is N or if Reason_for_PTcourse is null then return default
      IF  ( p_hesa_method IN ('8','9')  OR p_dlhe_pt_study = 'N' OR p_dlhe_reason_ptcrse IS NULL )  THEN
         -- default value processing
          p_hesa_intent := 'X' ;
      ELSIF p_dlhe_reason_ptcrse IS NOT NULL THEN
          -- return the hesa code mapped to dlhe reason for ptcourse
	  l_he_code_map_val.association_code := 'OSS_HESA_INTENT_ASSOC';
	  l_he_code_map_val.map2             := p_dlhe_reason_ptcrse;

          igs_he_extract2_pkg.get_map_values
                               (p_he_code_map_val   => l_he_code_map_val,
                                p_value_from        => 'MAP1',
                                p_return_value      => p_hesa_intent);
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_intent');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_intent;


   PROCEDURE get_job_while_study
          (p_hesa_method             IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study           IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_job_while_study    IN  igs_he_stdnt_dlhe.Job_while_studying%TYPE,
           p_hesa_empcrse            OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure identifies wether the student had the job while studying
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

   BEGIN
      IF  ( p_hesa_method IN ('3','4','8','9')  OR p_dlhe_pt_study = 'N' )  THEN
         -- default value processing
          p_hesa_empcrse := 'X' ;
      ELSIF p_dlhe_job_while_study = 'Y' THEN
         -- if job_while_studying = Y then return 1 else return 0
         p_hesa_empcrse := '1';
      ELSE
         p_hesa_empcrse := '0';
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_job_while_study');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_job_while_study;


   PROCEDURE get_emp_sponsorship
          (p_hesa_method          IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_hesa_empcrse         IN  igs_he_ex_rn_dat_fd.value%TYPE,
	   p_dlhe_pt_study        IN  igs_he_stdnt_dlhe.PT_Study%TYPE,
	   p_dlhe_emp_support     IN  igs_he_stdnt_dlhe.Employer_support1%TYPE,
           p_hesa_empspns         OUT NOCOPY VARCHAR2)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :  This procedure gets the HESA reason for employer support 1 to 5
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

     l_he_code_map_val               igs_he_code_map_val%ROWTYPE := NULL;

   BEGIN
      IF  ( p_hesa_method IN ('3','4','8','9') OR p_hesa_empcrse IN ('0','X') OR p_dlhe_pt_study = 'N' )  THEN
          -- default value processing
          p_hesa_empspns := 'X' ;
      ELSIF p_dlhe_emp_support = 'Y' THEN
         -- If employer support1 to 5 = Y then return 1 else return 0
         p_hesa_empspns := '1' ;
      ELSE
         p_hesa_empspns := '0' ;
      END IF ;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_emp_sponsorship');
          igs_ge_msg_stack.add;
          App_Exception.Raise_Exception;
   END get_emp_sponsorship;


END IGS_HE_EXTRACT_DLHE_FIELDS_PKG;

/
