--------------------------------------------------------
--  DDL for Package Body BEN_CWB_EMP_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_EMP_ELIG" as
/* $Header: bencwbee.pkb 120.6 2008/05/26 12:50:01 sgnanama noship $ */
g_package varchar2(60) := 'ben_cwb_emp_elig' ;
g_post_process_exception exception;

   FUNCTION get_person_name(p_group_per_in_ler_id IN NUMBER)
     RETURN VARCHAR2
   IS
     CURSOR wsm(v_group_per_in_ler_id in number) IS
      SELECT info.full_name
        FROM ben_cwb_person_info info
       WHERE info.group_per_in_ler_id = v_group_per_in_ler_id;
    l_person_name varchar2(2000);
  BEGIN
     OPEN wsm(p_group_per_in_ler_id);
      FETCH wsm INTO l_person_name;
     CLOSE wsm;

    RETURN l_person_name;
  END;

  /*******************************************************************************************/

   FUNCTION get_for_period(p_group_per_in_ler_id IN NUMBER)
     RETURN VARCHAR2
   IS
      CURSOR c11
      IS
         SELECT nvl(dsgn.wthn_yr_start_dt,dsgn.yr_perd_start_dt)||' - '||
         nvl(dsgn.wthn_yr_end_dt,dsgn.yr_perd_end_dt) forPeriod
           FROM ben_per_in_ler pil,
                ben_cwb_pl_dsgn dsgn
          WHERE pil.per_in_ler_id = p_group_per_in_ler_id
            AND pil.group_pl_id = dsgn.group_pl_id
            AND pil.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
            AND dsgn.oipl_id = -1
            AND dsgn.group_pl_id = dsgn.pl_id
            AND dsgn.group_oipl_id = dsgn.oipl_id;
        l_info   c11%ROWTYPE;
   BEGIN
       OPEN c11;
       FETCH c11 INTO l_info;
       CLOSE c11;

       RETURN l_info.forPeriod;
    END;

  /*******************************************************************************************/
  PROCEDURE isCompManagerRole
  (
    p_person_id IN   NUMBER
   ,retValue    OUT NOCOPY  VARCHAR2
  )
  IS
  cursor c1(c_role_id in number) is
      SELECT pei.person_id person_id, ppf.full_name person_name ,
             usr.user_name user_name, usr.user_id user_id
        FROM per_people_extra_info pei , per_all_people_f ppf ,
             fnd_user usr , pqh_roles rls
       WHERE information_type = 'PQH_ROLE_USERS' and
             pei.person_id = ppf.person_id
        AND  TRUNC(SYSDATE) BETWEEN ppf.effective_start_date and ppf.effective_end_date
         and usr.employee_id = ppf.person_id
         and rls.role_id = to_number(pei.pei_information3)
         and nvl(pei.pei_information5,'Y')='Y'
         and rls.role_id = c_role_id;
  cursor c2 is
       select role_id
         from pqh_roles
        where role_type_cd ='CWB';
  l_proc        varchar2(80) := g_package||'.isCompManagerRole';
  BEGIN
    hr_utility.set_location ('Entering '||l_proc,15);
    retValue := 'N';
    FOR rl in c2
    LOOP
      FOR person_in_role IN c1(rl.role_id)
        LOOP
          IF (person_in_role.person_id = p_person_id ) THEN
            retValue := 'Y';
          END IF;
        END LOOP;
    END LOOP;
  hr_utility.set_location ('Leaving '||l_proc,20);
  exception
           when others then
           retValue := null;
           raise;
  END;
  /*******************************************************************************************/

 /*******************************************************************************************/
  PROCEDURE updateEligibility
  (
    p_group_per_in_ler_id    NUMBER
   ,p_pl_pl_id               NUMBER
   ,p_pl_oipl_id             NUMBER
   ,p_pl_elig_flag           VARCHAR2
   ,p_pl_elig_change_status  VARCHAR2
   ,p_pl_person_rate_id      NUMBER
   ,p_o1_pl_id               NUMBER
   ,p_o1_oipl_id             NUMBER
   ,p_o1_elig_flag           VARCHAR2
   ,p_o1_elig_change_status  VARCHAR2
   ,p_o1_person_rate_id      NUMBER  default null
   ,p_o2_pl_id               NUMBER
   ,p_o2_oipl_id             NUMBER
   ,p_o2_elig_flag           VARCHAR2
   ,p_o2_elig_change_status  VARCHAR2
   ,p_o2_person_rate_id      NUMBER
   ,p_o3_pl_id               NUMBER
   ,p_o3_oipl_id             NUMBER
   ,p_o3_elig_flag           VARCHAR2
   ,p_o3_elig_change_status  VARCHAR2
   ,p_o3_person_rate_id      NUMBER
   ,p_o4_pl_id               NUMBER
   ,p_o4_oipl_id             NUMBER
   ,p_o4_elig_flag           VARCHAR2
   ,p_o4_elig_change_status  VARCHAR2
   ,p_o4_person_rate_id      NUMBER
   ,p_elig_ovrid_person_id   NUMBER
   ,p_elig_ovrid_dt          DATE
  )IS
    l_inelig_rsn_cd         VARCHAR2(4) := NULL;
    l_object_version_number NUMBER;
    l_ws_val                NUMBER;
    l_elig_flag             VARCHAR2(1);
    l_ws_start_date         DATE := hr_api.g_date;
    l_proc        VARCHAR2(80) := g_package||'.updateEligibility';

    CURSOR c_person_rate(v_person_rate_id IN VARCHAR2) IS
    SELECT  object_version_number
           ,ws_val
           ,elig_flag
	   ,ws_rt_start_date
      FROM ben_cwb_person_rates
     WHERE person_rate_id = v_person_rate_id;

  BEGIN
    hr_utility.set_location ('Entering '||l_proc,40);

    IF p_o1_elig_change_status = 'O1Y' THEN

      IF p_o1_elig_flag = 'N' THEN
         l_ws_val := NULL;
         l_inelig_rsn_cd := 'MGR';
	 l_ws_start_date := NULL;
      ELSE
         l_inelig_rsn_cd := NULL;
	 l_ws_start_date := hr_api.g_date;
      END IF;

      IF p_pl_elig_change_status = 'PY' THEN
        IF p_pl_elig_flag = 'Y' THEN
          OPEN c_person_rate(p_o1_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o1_pl_id
           ,p_oipl_id                => p_o1_oipl_id
           ,p_elig_flag              => p_o1_elig_flag
           ,p_ws_val                 => l_ws_val
           ,p_inelig_rsn_cd          => l_inelig_rsn_cd
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => l_ws_start_date
          );
        END IF;
       ELSE
          OPEN c_person_rate(p_o1_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
	  IF p_o1_elig_flag = 'N' THEN
		 l_ws_val := NULL;
		 l_inelig_rsn_cd := 'MGR';
		 l_ws_start_date := NULL;
          ELSE
		 l_inelig_rsn_cd := NULL;
		 l_ws_start_date := hr_api.g_date;
          END IF;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o1_pl_id
           ,p_oipl_id                => p_o1_oipl_id
           ,p_elig_flag              => p_o1_elig_flag
           ,p_ws_val                 => l_ws_val
           ,p_inelig_rsn_cd          => l_inelig_rsn_cd
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => l_ws_start_date
          );

          OPEN c_person_rate(p_pl_person_rate_id);
            FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          IF l_elig_flag = 'N' AND p_o1_elig_flag = 'Y' THEN
            ben_cwb_person_rates_api.update_person_rate
            (
              p_group_per_in_ler_id    => p_group_per_in_ler_id
             ,p_pl_id                  => p_pl_pl_id
             ,p_oipl_id                => p_pl_oipl_id
             ,p_elig_flag              => 'Y'
             ,p_elig_ovrid_dt          => p_elig_ovrid_dt
             ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
             ,p_object_version_number  => l_object_version_number
           );
          END IF;
       END IF;
     END IF;

     IF p_o2_elig_change_status = 'O2Y' THEN

             IF p_o2_elig_flag = 'N' THEN
                l_ws_val := NULL;
                l_inelig_rsn_cd := 'MGR';
		l_ws_start_date := NULL;
             ELSE
                l_inelig_rsn_cd := NULL;
		l_ws_start_date := hr_api.g_date;
             END IF;

             IF p_pl_elig_change_status = 'PY' THEN
               IF p_pl_elig_flag = 'Y' THEN
                 OPEN c_person_rate(p_o2_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o2_pl_id
                  ,p_oipl_id                => p_o2_oipl_id
                  ,p_elig_flag              => p_o2_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );
               END IF;
              ELSE
                 OPEN c_person_rate(p_o2_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
		  IF p_o2_elig_flag = 'N' THEN
			 l_ws_val := NULL;
			 l_inelig_rsn_cd := 'MGR';
			 l_ws_start_date := NULL;
		  ELSE
			 l_inelig_rsn_cd := NULL;
			 l_ws_start_date := hr_api.g_date;
		  END IF;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o2_pl_id
                  ,p_oipl_id                => p_o2_oipl_id
                  ,p_elig_flag              => p_o2_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );

                 OPEN c_person_rate(p_pl_person_rate_id);
                   FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 IF l_elig_flag = 'N' AND p_o2_elig_flag = 'Y' THEN
                   ben_cwb_person_rates_api.update_person_rate
                   (
                     p_group_per_in_ler_id    => p_group_per_in_ler_id
                    ,p_pl_id                  => p_pl_pl_id
                    ,p_oipl_id                => p_pl_oipl_id
                    ,p_elig_flag              => 'Y'
                    ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                    ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                    ,p_object_version_number  => l_object_version_number
                  );
                 END IF;
              END IF;
     END IF;

    IF p_o3_elig_change_status = 'O3Y' THEN

             IF p_o3_elig_flag = 'N' THEN
                l_ws_val := NULL;
                l_inelig_rsn_cd := 'MGR';
		l_ws_start_date := NULL;
             ELSE
                l_inelig_rsn_cd := NULL;
		l_ws_start_date := hr_api.g_date;
             END IF;

             IF p_pl_elig_change_status = 'PY' THEN
               IF p_pl_elig_flag = 'Y' THEN
                 OPEN c_person_rate(p_o3_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o3_pl_id
                  ,p_oipl_id                => p_o3_oipl_id
                  ,p_elig_flag              => p_o3_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );
               END IF;
              ELSE
                 OPEN c_person_rate(p_o3_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
		 IF p_o3_elig_flag = 'N' THEN
			 l_ws_val := NULL;
			 l_inelig_rsn_cd := 'MGR';
			 l_ws_start_date := NULL;
		  ELSE
			 l_inelig_rsn_cd := NULL;
			 l_ws_start_date := hr_api.g_date;
		  END IF;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o3_pl_id
                  ,p_oipl_id                => p_o3_oipl_id
                  ,p_elig_flag              => p_o3_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );

                 OPEN c_person_rate(p_pl_person_rate_id);
                   FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 IF l_elig_flag = 'N' AND p_o3_elig_flag = 'Y' THEN
                   ben_cwb_person_rates_api.update_person_rate
                   (
                     p_group_per_in_ler_id    => p_group_per_in_ler_id
                    ,p_pl_id                  => p_pl_pl_id
                    ,p_oipl_id                => p_pl_oipl_id
                    ,p_elig_flag              => 'Y'
                    ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                    ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                    ,p_object_version_number  => l_object_version_number
                  );
                 END IF;
              END IF;
     END IF;

    IF p_o4_elig_change_status = 'O4Y' THEN

             IF p_o4_elig_flag = 'N' THEN
                l_ws_val := NULL;
                l_inelig_rsn_cd := 'MGR';
		l_ws_start_date := NULL;
             ELSE
                l_inelig_rsn_cd := NULL;
		l_ws_start_date := hr_api.g_date;
             END IF;

             IF p_pl_elig_change_status = 'PY' THEN
               IF p_pl_elig_flag = 'Y' THEN
                 OPEN c_person_rate(p_o4_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o4_pl_id
                  ,p_oipl_id                => p_o4_oipl_id
                  ,p_elig_flag              => p_o4_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );
               END IF;
              ELSE
                 OPEN c_person_rate(p_o4_person_rate_id);
                  FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
		 IF p_o4_elig_flag = 'N' THEN
			 l_ws_val := NULL;
			 l_inelig_rsn_cd := 'MGR';
			 l_ws_start_date := NULL;
		  ELSE
			 l_inelig_rsn_cd := NULL;
			 l_ws_start_date := hr_api.g_date;
		  END IF;
                 ben_cwb_person_rates_api.update_person_rate
                 (
                   p_group_per_in_ler_id    => p_group_per_in_ler_id
                  ,p_pl_id                  => p_o4_pl_id
                  ,p_oipl_id                => p_o4_oipl_id
                  ,p_elig_flag              => p_o4_elig_flag
                  ,p_ws_val                 => l_ws_val
                  ,p_inelig_rsn_cd          => l_inelig_rsn_cd
                  ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                  ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                  ,p_object_version_number  => l_object_version_number
		  ,p_ws_rt_start_date       => l_ws_start_date
                 );

                 OPEN c_person_rate(p_pl_person_rate_id);
                   FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
                 CLOSE c_person_rate;
                 IF l_elig_flag = 'N' AND p_o4_elig_flag = 'Y' THEN
                   ben_cwb_person_rates_api.update_person_rate
                   (
                     p_group_per_in_ler_id    => p_group_per_in_ler_id
                    ,p_pl_id                  => p_pl_pl_id
                    ,p_oipl_id                => p_pl_oipl_id
                    ,p_elig_flag              => 'Y'
                    ,p_elig_ovrid_dt          => p_elig_ovrid_dt
                    ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
                    ,p_object_version_number  => l_object_version_number
                  );
                 END IF;
              END IF;
     END IF;


    IF p_pl_elig_change_status = 'PY' THEN

      OPEN c_person_rate(p_pl_person_rate_id);
      FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
      CLOSE c_person_rate;

      IF p_pl_elig_flag = 'N' THEN
       l_ws_val := NULL;
       l_inelig_rsn_cd := 'MGR';
       l_ws_start_date := NULL;
      ELSE
       l_inelig_rsn_cd := NULL;
       l_ws_start_date := hr_api.g_date;
       -- Need to call the routine which deletes all assignment changes
       -- as the person becomes ineligible.
      END IF;

      ben_cwb_person_rates_api.update_person_rate
      (
        p_group_per_in_ler_id    => p_group_per_in_ler_id
       ,p_pl_id                  => p_pl_pl_id
       ,p_oipl_id                => p_pl_oipl_id
       ,p_elig_flag              => p_pl_elig_flag
       ,p_ws_val                 => l_ws_val
       ,p_inelig_rsn_cd          => l_inelig_rsn_cd
       ,p_elig_ovrid_dt          => p_elig_ovrid_dt
       ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
       ,p_object_version_number  => l_object_version_number
       ,p_ws_rt_start_date       => l_ws_start_date
      );


      l_object_version_number := NULL;
      l_ws_val                := NULL;
      l_inelig_rsn_cd         := NULL;

      IF p_pl_elig_flag = 'N' THEN

        IF p_o1_oipl_id IS NOT NULL THEN
          OPEN c_person_rate(p_o1_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o1_pl_id
           ,p_oipl_id                => p_o1_oipl_id
           ,p_elig_flag              => 'N'
           ,p_ws_val                 => null
           ,p_inelig_rsn_cd          => 'MGR'
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => null
          );
        END IF;

        l_object_version_number := NULL;
	l_ws_val                := NULL;
        l_inelig_rsn_cd         := NULL;

        IF p_o2_oipl_id IS NOT NULL THEN
          OPEN c_person_rate(p_o2_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o2_pl_id
           ,p_oipl_id                => p_o2_oipl_id
           ,p_elig_flag              => 'N'
           ,p_ws_val                 => null
           ,p_inelig_rsn_cd          => 'MGR'
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => null
          );
        END IF;

        l_object_version_number := NULL;
        l_ws_val                := NULL;
        l_inelig_rsn_cd         := NULL;

        IF p_o3_oipl_id IS NOT NULL THEN
          OPEN c_person_rate(p_o3_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o3_pl_id
           ,p_oipl_id                => p_o3_oipl_id
           ,p_elig_flag              => 'N'
           ,p_ws_val                 => null
           ,p_inelig_rsn_cd          => 'MGR'
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => null
          );
        END IF;

        l_object_version_number := NULL;
        l_ws_val                := NULL;
        l_inelig_rsn_cd         := NULL;

        IF p_o4_oipl_id IS NOT NULL THEN
          OPEN c_person_rate(p_o4_person_rate_id);
           FETCH c_person_rate INTO l_object_version_number, l_ws_val,l_elig_flag,l_ws_start_date;
          CLOSE c_person_rate;
          ben_cwb_person_rates_api.update_person_rate
          (
            p_group_per_in_ler_id    => p_group_per_in_ler_id
           ,p_pl_id                  => p_o4_pl_id
           ,p_oipl_id                => p_o4_oipl_id
           ,p_elig_flag              => 'N'
           ,p_ws_val                 => null
           ,p_inelig_rsn_cd          => 'MGR'
           ,p_elig_ovrid_dt          => p_elig_ovrid_dt
           ,p_elig_ovrid_person_id   => p_elig_ovrid_person_id
           ,p_object_version_number  => l_object_version_number
	   ,p_ws_rt_start_date       => null
          );
        END IF;

      END IF;

    END IF;

    hr_utility.set_location ('Leaving '||l_proc,45);
  END;
 /*******************************************************************************************/

 /*******************************************************************************************/
  PROCEDURE cwb_emp_elig_start_process(
          p_plan_name                      in varchar2 default null
        , p_requestor_name                 in varchar2 default null
        , p_worksheet_manger               in varchar2 default null
        , p_relationship_id                in number
        , p_group_per_in_ler_id            in number
        )
    is
       l_proc varchar2(61) := g_package||':'||'cwb_emp_elig_start_process';
       l_itemkey  number := p_relationship_id;
       l_itemtype varchar2(60) := 'BENCWBFY';
       l_process_name varchar2(60) := 'CWB_EMP_ELIG';
       l_process_name_c varchar2(60);
    Begin

      -- hr_utility.trace_on (null, 'ORACLE');

       hr_utility.set_location ('Entering '||l_proc,50);

       hr_utility.set_location ('Seeded Elig Process Name'||l_process_name ,55);

       hr_utility.set_location ('Profile ::  '|| fnd_profile.value('BEN_CWB_EMP_ELIG_W_PROCESS') ,55);

       l_process_name :=  nvl(fnd_profile.value('BEN_CWB_EMP_ELIG_W_PROCESS'),'CWB_EMP_ELIG');

       hr_utility.set_location ('Elig Process Name After reading profile'||l_process_name ,55);

       wf_engine.createProcess(ItemType => l_itemtype,
             ItemKey  => l_itemkey,
             process  => l_process_name );

       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'PLAN_NAME'
             , avalue   => p_plan_name);
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'REQUESTOR_NAME'
             , avalue   => p_requestor_name);
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'WORKSHEET_MANAGER'
             , avalue   => p_worksheet_manger);
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'MANAGER_NAME'
             , avalue   => get_person_name(p_group_per_in_ler_id));
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'FROM_ROLE'
             , avalue   => p_requestor_name);
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'TRANSACTION_ID'
             , avalue   => p_relationship_id);
       wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'FOR_PERIOD'
             , avalue   => get_for_period (p_group_per_in_ler_id));
       wf_engine.SetItemOwner(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , owner    => p_requestor_name);
       wf_engine.StartProcess (  ItemType => l_itemtype,
                                 ItemKey  => l_ItemKey );
      hr_utility.set_location ('Leaving '||l_proc,55);
      exception
         when others then
      hr_utility.set_location ('Error occured cwb_emp_elig_start_process',60);
    END;
  /*******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE cwb_emp_elig_appr_api
  ( p_ws_person_id        in number default null
  , p_rcvr_person_id      in number default null
  , p_plan_name           in varchar2
  , p_relationship_id     in number
  , p_group_per_in_ler_id in number
  )
  IS
  l_proc varchar2(61) := g_package||':'||'cwb_emp_elig_appr_api';
  l_itemkey  number;
  l_itemtype varchar2(60)     := 'BENCWBFY';
  l_process_name varchar2(240) := 'CWB_EMP_ELIG';
  l_rcvr_user_name varchar2(240);
  l_ws_user_name   varchar2(240);
  l_start_process varchar2(10) := 'N';
  cursor c1 is select user_name from fnd_user
                where employee_id = p_rcvr_person_id;
  cursor c2 is select user_name from fnd_user
                  where employee_id = p_ws_person_id;
  BEGIN
  hr_utility.set_location ('Entering '||l_proc,85);
  if p_rcvr_person_id is null then
      hr_utility.set_location ('receiver person id to be passed ',90);
  else
      open c1;
      fetch c1 into l_rcvr_user_name;
      if c1%notfound then
      hr_utility.set_location ('fnd user does not exist'||p_rcvr_person_id,95);
       else
         l_start_process := 'Y' ;
       end if;
         close c1;
  end if;
  if p_ws_person_id is null then
    hr_utility.set_location ('wroksheet manager person id to be passed ',95);
  else
     open c2;
     fetch c2 into l_ws_user_name;
     if c2%notfound then
        l_start_process := 'N';
     else
        l_start_process := 'Y' ;
     end if;
     close c2;
  end if;
     if l_start_process = 'Y' then
        cwb_emp_elig_start_process
        ( p_plan_name                      => p_plan_name
        , p_requestor_name                 => l_rcvr_user_name
        , p_worksheet_manger               => l_ws_user_name
        , p_relationship_id                => p_relationship_id
        , p_group_per_in_ler_id            => p_group_per_in_ler_id
        );
     end if;
     hr_utility.set_location ('Leaving '||l_proc,100);
   exception
   when others then
      hr_utility.set_location ('Error occured cwb_emp_elig_appr_api',105);
  END;
  /*******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE select_next_approver
  ( itemtype    IN  VARCHAR2
  , itemkey     IN  VARCHAR2
  , actid       IN  NUMBER
  , funcmode    IN  VARCHAR2
  , result      OUT NOCOPY VARCHAR2
  )
  IS
  cursor approver_name(c_approver_id IN NUMBER) is select user_name from fnd_user
                          where employee_id = c_approver_id;
  l_proc varchar2(61) := g_package||':'||'select_next_approver';
  l_is_ame_used VARCHAR2(240) := 'Y';
  c_next_approver_out ame_util.approverRecord;
  l_approver_name VARCHAR2(240);
  BEGIN
    hr_utility.set_location ('Entering '||l_proc,110);
      ame_api.getnextapprover
      (
        applicationIdIn =>805,
        transactionIdIn =>itemkey,
        transactionTypeIn =>'EMPELIG',
        nextApproverOut =>c_next_approver_out);
      IF(c_next_approver_out.person_id is not null) THEN
        OPEN approver_name(c_next_approver_out.person_id);
        FETCH approver_name INTO l_approver_name;
        IF approver_name%NOTFOUND then
          result := 'COMPLETE:' ||'APPROVER_NOT_FOUND';
        ELSE
          wf_engine.SetItemAttrText(itemtype => itemtype
                                   , itemkey => itemkey
                                   , aname => 'APPROVER_NAME'
                                   , avalue   => l_approver_name );
         update ben_transaction
            set attribute36 = l_approver_name,
                attribute38 = to_char(sysdate,'yyyy/mm/dd'),
                attribute35 = c_next_approver_out.person_id
          where attribute1 = itemkey
            and transaction_type = 'EMPELIGEMP';

         wf_engine.SetItemAttrNumber(itemtype => itemtype
                                   , itemkey => itemkey
                                   , aname => 'APPROVER_ID'
                                   , avalue   => c_next_approver_out.person_id );
         result := 'COMPLETE:' ||'CWB_APPROVER_FOUND';
        END IF;
        close approver_name;
      ELSE
        result := 'COMPLETE:' ||'APPROVER_NOT_FOUND';
      END IF;
    hr_utility.set_location ('Leaving '||l_proc,115);
    exception
        when others then
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_OCCURED_AT'
                     , avalue   => 'Select Next Approver Node');
        wf_engine.SetItemAttrText(itemtype => itemtype
             , itemkey  => itemkey
             , aname    => 'ERROR_MESSAGE'
             , avalue   => 'Unable to get the next approver or failed to update the transaction table');
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_SQLERRM'
             , avalue   => SQLERRM);
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_SQLCODE'
             , avalue   => SQLCODE);
        result := 'COMPLETE:'||'EMP_ELIG_ERROR';
     END;
  /******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE store_transaction
    ( itemtype    IN  VARCHAR2
    , itemkey     IN  VARCHAR2
    , actid       IN  NUMBER
    , funcmode    IN  VARCHAR2
    , result      OUT NOCOPY VARCHAR2
    )
    IS
    l_proc varchar2(61) := g_package||':'||'store_transaction';
    l_approver_name VARCHAR2(240);
    l_approver_id   NUMBER;
    l_comments  VARCHAR(2000);
    l_notification_id NUMBER;
    l_itemkey VARCHAR(240) := itemkey;
    l_itemtype VARCHAR(240) := itemtype;
    cursor employeeId (c_approver_name IN VARCHAR2) is select employee_id from fnd_user
                          where user_name = l_approver_name;
    BEGIN
      hr_utility.set_location ('Entering '||l_proc,135);
      l_approver_name :=wf_engine.getitemattrtext(itemtype => itemtype ,
                                                  itemkey => itemkey,
                                                  aname   => 'APPROVER_NAME');
      l_approver_id :=wf_engine.getitemattrNumber(itemtype => itemtype ,
                                                  itemkey => itemkey,
                                                  aname   => 'APPROVER_ID');
       IF(l_approver_name is not null) THEN
               OPEN employeeId(l_approver_name);
               FETCH employeeId INTO l_approver_id;
               IF employeeId%NOTFOUND then
                hr_utility.set_location ('Was not able to get the approver name in store transaction',145);
               ELSE
                 ame_api.updateApprovalStatus2(applicationIdIn => 805,
                                   transactionIdIn => itemkey,
                                   approvalStatusIn => ame_util.approvedStatus,
                                   approverPersonIdIn => l_approver_id,
                                   transactionTypeIn => 'EMPELIG');
               END IF;
               close employeeId;
      wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'FROM_ROLE'
             , avalue   => l_approver_name);
      END IF;
      result := 'COMPLETE:'||'EMP_ELIG_SUCCESS' ;
      hr_utility.set_location ('Leaving '||l_proc,10);
      exception
      when others then
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_OCCURED_AT'
                     , avalue   => 'Store transaction Node');
        wf_engine.SetItemAttrText(itemtype => itemtype
             , itemkey  => itemkey
             , aname    => 'ERROR_MESSAGE'
             , avalue   => 'Unable to update ame approver status');
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_SQLERRM'
             , avalue   => SQLERRM);
        wf_engine.SetItemAttrText(itemtype => itemtype
                     , itemkey  => itemkey
                     , aname    => 'ERROR_SQLCODE'
             , avalue   => SQLCODE);
          result := 'COMPLETE:'||'EMP_ELIG_ERROR';
  END;
  /*******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE store_rejection
  ( itemtype    IN  VARCHAR2
  , itemkey     IN  VARCHAR2
  , actid       IN  NUMBER
  , funcmode    IN  VARCHAR2
  , result      OUT NOCOPY VARCHAR2
  )
  IS
   l_proc varchar2(61) := g_package||':'||'store_rejection';
   l_approver_id NUMBER;
   l_approver_name VARCHAR2(1000);
   l_itemkey VARCHAR(240) := itemkey;
   l_itemtype VARCHAR(240) := itemtype;
  BEGIN
   hr_utility.set_location ('Entering '||l_proc,150);
   l_approver_id :=wf_engine.getitemattrNumber(itemtype => itemtype ,
                                               itemkey => itemkey,
                                               aname   => 'APPROVER_ID');
   l_approver_name :=wf_engine.getitemattrtext(itemtype => itemtype ,
                                               itemkey => itemkey,
                                               aname   => 'APPROVER_NAME');
   wf_engine.SetItemAttrText(itemtype => l_itemtype
             , itemkey  => l_itemkey
             , aname    => 'FROM_ROLE'
             , avalue   => l_approver_name);
   result := 'COMPLETE:';
   hr_utility.set_location ('Leaving '||l_proc,155);
   exception
      when others then
   result := null;
  END;
  /*******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE store_approval
    ( itemtype    IN  VARCHAR2
    , itemkey     IN  VARCHAR2
    , actid       IN  NUMBER
    , funcmode    IN  VARCHAR2
    , result      OUT NOCOPY VARCHAR2
    )
    IS
     l_proc varchar2(61) := g_package||':'||'store_approval';
     l_approver_id NUMBER;
     l_comments VARCHAR2(500);
     l_errmsg   VARCHAR2(500) := 'Unable to update the choice records after approval';
    cursor upd_emp_elig is
    select  tran_tbl.attribute2       group_per_in_ler_id
            -- Plan Level transaction values
           ,tran_tbl.attribute18      pl_pl_id
           ,tran_tbl.attribute19      pl_oipl_id
           ,tran_tbl.attribute7       pl_status
           ,tran_tbl.attribute12      pl_change_status
           ,tran_tbl.attribute17      pl_person_rate_id
           -- Option1 Level transaction values
           ,tran_tbl.attribute21      o1_pl_id
           ,tran_tbl.attribute22      o1_oipl_id
           ,tran_tbl.attribute8       o1_status
           ,tran_tbl.attribute13      o1_change_status
           ,tran_tbl.attribute20      o1_person_rate_id
           -- Option2 Level transaction values
           ,tran_tbl.attribute24      o2_pl_id
           ,tran_tbl.attribute25      o2_oipl_id
           ,tran_tbl.attribute9       o2_status
           ,tran_tbl.attribute14      o2_change_status
           ,tran_tbl.attribute23      o2_person_rate_id
           -- Option3 Level transaction values
           ,tran_tbl.attribute27      o3_pl_id
           ,tran_tbl.attribute28      o3_oipl_id
           ,tran_tbl.attribute10      o3_status
           ,tran_tbl.attribute15      o3_change_status
           ,tran_tbl.attribute26      o3_person_rate_id
           -- Option4 Level transaction values
           ,tran_tbl.attribute30      o4_pl_id
           ,tran_tbl.attribute31      o4_oipl_id
           ,tran_tbl.attribute11      o4_status
           ,tran_tbl.attribute16      o4_change_status
           ,tran_tbl.attribute29      o4_person_rate_id
           ,tran_tbl.attribute37      ovrd_person_id
           ,pil.per_in_ler_stat_cd    ler_stat
      from ben_transaction tran_tbl,
           ben_per_in_ler pil
     where tran_tbl.attribute1 = itemkey
       and tran_tbl.transaction_type = 'EMPELIGEMP'
       and to_number(tran_tbl.attribute2) = pil.per_in_ler_id;
    BEGIN
     hr_utility.set_location ('Entering '||l_proc,160);

     ben_cwb_summary_pkg.delete_pl_sql_tab;

     for emp_elig in upd_emp_elig
       loop
         If emp_elig.ler_stat = 'STRTD' THEN
         updateEligibility
         (
            p_group_per_in_ler_id      => to_number(emp_elig.group_per_in_ler_id)
            -- Plan Level Parameters
           ,p_pl_pl_id                 => to_number(emp_elig.pl_pl_id)
           ,p_pl_oipl_id               => to_number(emp_elig.pl_oipl_id)
           ,p_pl_elig_flag             => emp_elig.pl_status
           ,p_pl_elig_change_status     => emp_elig.pl_change_status
           ,p_pl_person_rate_id        => to_number(emp_elig.pl_person_rate_id)
           -- Option1 Level Parameters
           ,p_o1_pl_id                 => to_number(emp_elig.o1_pl_id)
           ,p_o1_oipl_id               => to_number(emp_elig.o1_oipl_id)
           ,p_o1_elig_flag             => emp_elig.o1_status
           ,p_o1_elig_change_status    => emp_elig.o1_change_status
           ,p_o1_person_rate_id        => to_number(emp_elig.o1_person_rate_id)
           -- Option2 Level Parameters
           ,p_o2_pl_id                 => to_number(emp_elig.o2_pl_id)
           ,p_o2_oipl_id               => to_number(emp_elig.o2_oipl_id)
           ,p_o2_elig_flag             => emp_elig.o2_status
           ,p_o2_elig_change_status     => emp_elig.o2_change_status
           ,p_o2_person_rate_id        => to_number(emp_elig.o2_person_rate_id)
           -- Option3 Level Parameters
           ,p_o3_pl_id                 => to_number(emp_elig.o3_pl_id)
           ,p_o3_oipl_id               => to_number(emp_elig.o3_oipl_id)
           ,p_o3_elig_flag             => emp_elig.o3_status
           ,p_o3_elig_change_status     => emp_elig.o3_change_status
           ,p_o3_person_rate_id        => to_number(emp_elig.o3_person_rate_id)
           -- Option4 Level Parameters
           ,p_o4_pl_id                 => to_number(emp_elig.o4_pl_id)
           ,p_o4_oipl_id               => to_number(emp_elig.o4_oipl_id)
           ,p_o4_elig_flag             => emp_elig.o4_status
           ,p_o4_elig_change_status     => emp_elig.o4_change_status
           ,p_o4_person_rate_id        => to_number(emp_elig.o4_person_rate_id)

           ,p_elig_ovrid_person_id  => to_number(emp_elig.ovrd_person_id)
           ,p_elig_ovrid_dt         => sysdate
         );
        ELSE
         l_errmsg := 'Unable to update the choice record as it does not have a started life event';
         raise g_post_process_exception;
        END IF;
       end loop;

      ben_cwb_summary_pkg.save_pl_sql_tab;

      result := 'COMPLETE:'||'EMP_ELIG_SUCCESS' ;
      hr_utility.set_location ('Leaving '||l_proc,165);
      exception
      when others then
        wf_engine.SetItemAttrText( itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'ERROR_OCCURED_AT'
                                  ,avalue   => 'Store approval Node');
        wf_engine.SetItemAttrText(itemtype => itemtype
                                 ,itemkey  => itemkey
                                 ,aname    => 'ERROR_MESSAGE'
                                 ,avalue   => l_errmsg);
        wf_engine.SetItemAttrText(itemtype => itemtype
                                ,itemkey  => itemkey
                                ,aname    => 'ERROR_SQLERRM'
                                ,avalue   => SQLERRM);
        wf_engine.SetItemAttrText(itemtype => itemtype
                                 ,itemkey  => itemkey
                                 ,aname    => 'ERROR_SQLCODE'
                                 ,avalue   => SQLCODE);
          result := 'COMPLETE:'||'EMP_ELIG_ERROR';
  END;
  /*******************************************************************************************/

  /*******************************************************************************************/
  PROCEDURE is_req_wsmgr_same
  ( itemtype    IN  VARCHAR2
  , itemkey     IN  VARCHAR2
  , actid       IN  NUMBER
  , funcmode    IN  VARCHAR2
  , result      OUT NOCOPY VARCHAR2
  )
  IS
  l_proc varchar2(61) := g_package||':'||'is_req_wsmgr_same';
  l_worksheet_manager VARCHAR2(240);
  l_requestor         VARCHAR2(240);
  BEGIN
   hr_utility.set_location ('Entering '||l_proc,170);
   l_worksheet_manager :=wf_engine.getitemattrText(itemtype => itemtype ,
                                                 itemkey => itemkey,
                                                 aname   => 'WORKSHEET_MANAGER');
   l_requestor :=wf_engine.getitemattrText(itemtype => itemtype ,
                                                 itemkey => itemkey,
                                                 aname   => 'REQUESTOR_NAME');
   IF(l_worksheet_manager = l_requestor) THEN
     result := 'COMPLETE:' ||'Y';
   ELSE
     result := 'COMPLETE:' ||'N';
   END IF;
   hr_utility.set_location ('Leaving '||l_proc,175);
    exception
         when others then
   result := null;
  END;
  /*******************************************************************************************/

 /*******************************************************************************************/
  PROCEDURE remove_transaction
  ( itemtype    IN  VARCHAR2
  , itemkey     IN  VARCHAR2
  , actid       IN  NUMBER
  , funcmode    IN  VARCHAR2
  , result      OUT NOCOPY VARCHAR2
  )
  IS
  l_proc varchar2(61) := g_package||':'||'remove_transaction';
  BEGIN
   hr_utility.set_location ('Entering '||l_proc,180);
   update ben_transaction
      set STATUS='PROCESSED'
    where attribute1 = itemkey
      and transaction_type='EMPELIGHDR';
   update ben_transaction
      set STATUS='PROCESSED'
    where transaction_type = 'EMPELIGEMP'
      and attribute1 = itemkey;
   result := 'COMPLETE:';
   hr_utility.set_location ('Leaving '||l_proc,185);
    exception
         when others then
            result := null;
  END;
  /*******************************************************************************************/
END;

/
