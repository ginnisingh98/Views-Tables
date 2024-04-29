--------------------------------------------------------
--  DDL for Package Body PQP_UK_VEHICLE_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UK_VEHICLE_TEMPLATE" AS
/* $Header: pqukcmtp.pkb 120.0 2005/05/29 02:12:56 appldev noship $ */

/*========================================================================
 *                        CREATE_USER_INIT_TEMPLATE
 *=======================================================================*/
FUNCTION create_user_template
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_veh_type              in varchar2
           ,p_table_indicator_flg   in varchar2
           ,p_table_name            in varchar2
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_bg_id                 in number
           )
   RETURN NUMBER IS
   --


   /*--------------------------------------------------------------------
    The input values are explained below : V-varchar2, D-Date, N-number
      Input-Name            Type   Valid Values/Explaination
      ----------            ----   --------------------------------------
      p_ele_name             (V) - User i/p Element name
      p_ele_reporting_name   (V) - User i/p reporting name
      p_ele_description      (V) - User i/p Description
      p_ele_classification   (V) - 'Pre-Tax Deductions'
      p_ben_class_id         (N) - '' - not used
      p_ele_category         (V) - 'E'/'G' (403B/457)
      p_ele_processing_type  (V) - 'R'/'N' (Recurring/Non-recurring)
      p_ele_priority         (N) - User i/p priority
      p_ele_standard_link    (V) - 'Y'/'N'  (default N)
      p_ele_proc_runtype     (V) - 'REG'/'ALL'
      p_ele_calc_rule        (V) - 'FA'/'PE'  (Flat amount/Percentage)
      p_ele_eff_start_date   (D) - Trunc(start date)
      p_ele_eff_end_date     (D) - Trunc(end date)
      p_bg_id                (N) - Business group id
   ----------------------------------------------------------------------*/
   --
   l_mileage_rs_element_type_id  number;
   l_template_id                 NUMBER(9);
   l_base_element_type_id        NUMBER(9);
   l_source_template_id          NUMBER(9);
   l_object_version_number       NUMBER(9);
   l_proc                        VARCHAR2(80) :=
                          'pqp_uk_vehicle_template.create_user_template';
   l_co_car                      VARCHAR2(3);
   l_priv_car                    VARCHAR2(3);
   l_lumpsum                     VARCHAR2(3);
   l_covan                       VARCHAR2(3);
   l_result                      VARCHAR2(3);
   l_twowheel                    VARCHAR2(3);
   l_ip_name                     VARCHAR2(40);
   l_pedal                       VARCHAR2(3);
   l_excomp_id                   VARCHAR2(3);
   l_balfeed_excar               VARCHAR2(3);
   l_balfeed_exmc                VARCHAR2(3);
   l_balfeed_expc                VARCHAR2(3);

   l_eei_info_id                 NUMBER;
   l_ovn_eei                     NUMBER;
   l_sub                         VARCHAR2(30);
   l_element_type_id             NUMBER;
   l_lumptemp                    VARCHAR2(40);
   l_ele_obj_ver_number          NUMBER;
   l_input_id                    NUMBER;
   l_ip_object_version_number    NUMBER;
   --
   TYPE t_lump_bal IS TABLE OF VARCHAR2(80)
   INDEX BY BINARY_INTEGER;

    l_lump                      t_lump_bal;

   CURSOR c1 (c_ele_name varchar2) is
   SELECT element_type_id, object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id    = l_template_id
     AND  element_name   = c_ele_name;
   --
   -- cursor to fetch the core element id
   --
   CURSOR c5 (c_element_name in varchar2) is
   SELECT ptco.core_object_id
   FROM   pay_shadow_element_types psbt,
          pay_template_core_objects ptco
   WHERE  psbt.template_id      = l_template_id
     AND  psbt.element_name     = c_element_name
     AND  ptco.template_id      = psbt.template_id
     AND  ptco.shadow_object_id = psbt.element_type_id
     AND  ptco.core_object_type = 'ET';

   CURSOR c_input_id (c_element_type_id NUMBER) IS
   SELECT name,input_value_id,object_version_number
     FROM pay_shadow_input_values
    WHERE element_type_id= c_element_type_id
      AND name IN ('Two Wheeler Type','User Rates Table');
   --
   --======================================================================
   --                     FUNCTION GET_TEMPLATE_ID
   --======================================================================
   FUNCTION get_template_id (p_legislation_code    in varchar2 )
   RETURN number IS
     --
  --   l_template_id   NUMBER(9);
     l_template_name VARCHAR2(80);
   l_proc  varchar2(60)       := 'pqp_uk_vehicle_template.get_template_id';
     --
     CURSOR c4  is
     SELECT template_id
     FROM   pay_element_templates
     WHERE  template_name     = l_template_name
     AND    legislation_code  = p_legislation_code
     AND    template_type     = 'T'
     AND    business_group_id is NULL;
     --
   BEGIN
      --
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      l_template_name  := 'PQP MILEAGE CLAIM';
      --
      hr_utility.set_location(l_proc, 30);
      --
      for c4_rec in c4 loop
         l_template_id   := c4_rec.template_id;
      end loop;
      --
      hr_utility.set_location('Leaving: '||l_proc, 100);
      --
      RETURN l_template_id;
      --
   END get_template_id;

  -----------------------------------------------------------------------------
    ---  Procedure Delete  balance feeds
  -----------------------------------------------------------------------------
/*   PROCEDURE delete_balance_feeds(l_sub_type IN VARCHAR2,l_name IN VARCHAR2)
   is
     l_reg_earn_input_value_id          number;
     l_reg_earn_element_type_id         number;
     l_reg_earn_classification_id       number;
     l_scale                            number;
     l_balance_type_id                  number;
     TYPE t_balance_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
     l_chk_stat                         varchar2(10):='TRUE' ;
     l_balance_name  t_balance_name ;

     CURSOR c1_delinput(lc_sub_type Varchar2,lc_name varchar2) IS
               SELECT input_value_id,
                      piv.name,
                      piv.element_type_id
                 FROM pay_input_values_f piv,
                      pay_element_types_f pet
                 WHERE element_name= p_ele_name||' '||lc_sub_type
                   AND piv.element_type_id=pet.element_type_id
                   AND  (piv.business_group_id =p_bg_id OR piv.business_group_id IS NULL)
                   AND piv.name =lc_name
                   AND  (piv.legislation_code='GB' OR piv.legislation_code IS NULL);

     CURSOR c2_delbal (p_balance_name varchar2) IS
              SELECT  pbt.BALANCE_TYPE_ID
                FROM  pay_balance_types pbt
               WHERE pbt.BALANCE_NAME     = p_balance_name
                 AND pbt.lEGISLATION_CODE = 'GB'
                 AND  (pbt.legislation_code='GB' OR pbt.legislation_code IS NULL);

     CURSOR c3_delfeed (p_input number,p_bal_type_id number) IS
              SELECT  balance_feed_id
                FROM  pay_balance_feeds
               WHERE input_value_id=p_input
                 AND  balance_type_id=p_bal_type_id
                 AND  (business_group_id =p_bg_id OR business_group_id IS NULL)
                 AND  (legislation_code='GB' OR legislation_code IS NULL);

     c1_rec                       c1_delinput%rowtype;
     c2_rec                       c2_delbal%rowtype;
     c3_rec                       c3_delfeed%rowtype;

   BEGIN

     IF l_name ='Pay Value'THEN

            l_balance_name(1) :='Taxable Pay';
            l_balance_name(2) :='Attachable';

     END IF;


    OPEN c1_delinput(l_sub_type,l_name);


          LOOP

           FETCH c1_delinput INTO c1_rec;
           EXIT WHEN c1_delinput%NOTFOUND;

              l_reg_earn_input_value_id :=c1_rec.input_value_id;

           FOR i IN 1..l_balance_name.count
            LOOP

            OPEN c2_delbal(l_balance_name(i));
                  LOOP
                  FETCH c2_delbal INTO c2_rec;
                  EXIT WHEN c2_delbal%NOTFOUND;
                    l_balance_type_id   :=c2_rec.BALANCE_TYPE_ID;


            OPEN c3_delfeed(l_reg_earn_input_value_id ,l_balance_type_id  );
                  LOOP
                  FETCH c3_delfeed INTO c3_rec;
                  EXIT WHEN c3_delfeed%NOTFOUND;

              hr_balances.del_balance_feed(
                     p_option                       =>    'DEL_MANUAL_FEED'  ,
                     P_delete_mode                  =>    'DELETE'     ,
                     P_balance_feed_id              =>    c3_rec.balance_feed_id  ,
                     P_input_value_id               =>    c1_rec.input_value_id ,
                     P_element_type_id              =>    c1_rec.element_type_id   ,
                     P_primary_classification_id    =>    NULL  ,
                     P_sub_classification_id        =>    NULL     ,
                     P_sub_classification_rule_id   =>    NULL      ,
                     P_balance_type_id              =>    c2_rec.BALANCE_TYPE_ID      ,
                     P_session_date                 =>    p_ele_eff_start_date    ,
                     P_effective_end_date           =>    p_ele_eff_start_date    ,
                     P_legislation_code             =>    NULL,
                     P_mode                         =>    'USER');

                   END LOOP;
            CLOSE c3_delfeed;
          END LOOP;
         CLOSE c2_delbal;
         END LOOP;
        END LOOP;
     CLOSE c1_delinput ;



END delete_balance_feeds;*/

-----------------------------------------------------------------------------
    --- End Procedure Delete balance feeds
  -----------------------------------------------------------------------------
--------------------------------------------------------------------------------------
---Procedure Create balance feeds
------------------------------------------------------------------------------------

PROCEDURE create_balance_feeds
   is
     l_reg_earn_input_value_id          number;
     l_reg_earn_element_type_id         number;
     l_reg_earn_classification_id       number;
     l_scale                            number;
     l_balance_type_id                  number;
     TYPE t_balance_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
     l_chk_stat                         varchar2(10):='TRUE' ;
     l_balance_name      VARCHAR2(15);  ---t_balance_name ;
     l_balance_name1     VARCHAR2(15);  ---t_balance_name ;
CURSOR c1 IS SELECT input_value_id,piv.name,
                    element_name
                 FROM pay_input_values piv,
                      pay_element_types pet
                 WHERE element_name IN ( p_ele_name||' NIable'
                                        )
                   AND piv.element_type_id=pet.element_type_id
                   AND  piv.business_group_id =p_bg_id
                   AND piv.name IN ('Pay Value');

    CURSOR c2 (p_balance_name varchar2) IS
    SELECT  pbt.BALANCE_TYPE_ID
      FROM  pay_balance_types pbt
      WHERE pbt.BALANCE_NAME     = p_balance_name
        AND pbt.lEGISLATION_CODE = 'GB';

 c1_rec                       c1%rowtype;
 c2_rec                       c2%rowtype;


 BEGIN
--       l_balance_name :='NIable Pay';

--       l_balance_name1 :='Taxable Pay';

 OPEN c1;
          LOOP
           FETCH c1 INTO c1_rec;
           EXIT WHEN c1%NOTFOUND;

           l_reg_earn_input_value_id :=c1_rec.input_value_id;

           IF c1_rec.element_name= p_ele_name||' NIable'THEN
            l_balance_name :='NIable Pay';


           END IF;

             OPEN c2(l_balance_name);
              LOOP
              FETCH c2 INTO c2_rec;
              EXIT WHEN c2%NOTFOUND;

                l_balance_type_id   :=c2_rec.BALANCE_TYPE_ID;


                hr_balances.ins_balance_feed(
                p_option                     => 'INS_MANUAL_FEED',
                p_input_value_id             => l_reg_earn_input_value_id,
                p_element_type_id            => NULL,
                p_primary_classification_id  => NULL,
                p_sub_classification_id      => NULL,
                p_sub_classification_rule_id => NULL,
                p_balance_type_id            => l_balance_type_id,
                p_scale                      => 1,
                p_session_date               => p_ele_eff_start_date,
                p_business_group             => p_bg_id,
                p_legislation_code           => NULL,
                p_mode                       => 'USER');

              END LOOP;
               CLOSE c2;

         END LOOP;
       CLOSE c1;

     END;







------------------------------------------------------------------------------------
----Create balance feed ends

----------------------------------------------------------------------------------



------------------------------------------------------------------------------------
   -----------------------------------------------------------------------------
    ---  Procedure Update Formula id for an Input value
  -----------------------------------------------------------------------------
 PROCEDURE upd_inputval_formula(p_ele_type     IN NUMBER,
                                p_inputname IN VARCHAR2,
                                p_formula_name IN VARCHAR2)
   IS
  CURSOR c_get_inputval is
               SELECT input_value_id,
                      piv.name,
                      piv.element_type_id
                FROM pay_input_values_f piv,
                     pay_element_types_f pet
               WHERE piv.element_type_id =p_ele_type
                 AND piv.element_type_id    = pet.element_type_id
                 AND piv.business_group_id  = p_bg_id
                 AND piv.name =p_inputname;


   CURSOR c_get_id IS
               SELECT formula_id
                 FROM ff_formulas
                WHERE  FORMULA_name=p_formula_name
                  AND  p_ele_eff_start_date
              BETWEEN effective_start_date
                  AND effective_end_date
                  AND legislation_code='GB';

   CURSOR c_get_valueset IS
      SELECT ffvs.flex_value_set_id
        FROM fnd_flex_value_sets ffvs
       WHERE flex_value_set_name = 'PQP_PURPOSE_LIST';

  c3_rec c_get_valueset%ROWTYPE;
  c1_rec c_get_inputval%ROWTYPE;
  c2_rec c_get_id%ROWTYPE;
  BEGIN
   IF p_inputname = 'Purpose' THEN

    OPEN c_get_valueset;
     FETCH c_get_valueset INTO c3_rec;
    CLOSE c_get_valueset;

    OPEN c_get_inputval ;
     FETCH c_get_inputval INTO c1_rec;
    CLOSE c_get_inputval;

    UPDATE pay_input_values_f
             SET value_set_id=c3_rec.flex_value_set_id,
                 warning_or_error='W'
             WHERE input_value_id=c1_rec.input_value_id
               AND element_type_id=p_ele_type;
   ELSE


    OPEN c_get_inputval ;
     LOOP
      FETCH c_get_inputval INTO c1_rec;
      EXIT WHEN c_get_inputval%NOTFOUND;
       OPEN c_get_id ;
        LOOP
         FETCH c_get_id INTO c2_rec;
         EXIT WHEN c_get_id %NOTFOUND;

          UPDATE pay_input_values_f
             SET formula_id=c2_rec.formula_id,
                 warning_or_error='E'
           WHERE input_value_id=c1_rec.input_value_id
             AND element_type_id=p_ele_type;
       END LOOP;
      CLOSE c_get_id;
     END LOOP;
    CLOSE c_get_inputval ;
   END IF;



   EXCEPTION
   --------
   WHEN OTHERS THEN
   NULL;



 END  upd_inputval_formula;
-----------------------------------------------------------------------------
    ---  End Procedure Update Formula id for an Input value
  -----------------------------------------------------------------------------

   --
   --=======================================================================
   --                FUNCTION GET_OBJECT_ID
   --=======================================================================
   FUNCTION get_object_id (p_object_type    in varchar2,
                           p_object_name   in varchar2)
   RETURN NUMBER is
     --
     l_object_id  NUMBER      := NULL;
     l_proc   varchar2(60)    := 'pqp_uk_vehicle_template.get_object_id';
     --
     CURSOR c2 (c_object_name varchar2) is
           SELECT element_type_id
             FROM   pay_element_types_f
            WHERE  element_name      = c_object_name
              AND  business_group_id = p_bg_id;
     --
     CURSOR c3 (c_object_name in varchar2) is
          SELECT ptco.core_object_id
            FROM   pay_shadow_balance_types psbt,
                   pay_template_core_objects ptco
           WHERE  psbt.template_id      = l_template_id
             AND  psbt.balance_name     = c_object_name
             AND  ptco.template_id      = psbt.template_id
             AND  ptco.shadow_object_id = psbt.balance_type_id;
     --
   BEGIN
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      if p_object_type = 'ELE' then
         for c2_rec in c2 (p_object_name) loop
            l_object_id := c2_rec.element_type_id;  -- element id
         end loop;
      elsif p_object_type = 'BAL' then
         for c3_rec in c3 (p_object_name) loop
            l_object_id := c3_rec.core_object_id;   -- balance id
         end loop;
      end if;
      --
      hr_utility.set_location('Leaving: '||l_proc, 50);
      --
      RETURN l_object_id;
      --
   END get_object_id;
   --
--===============================================================================
--                         MAIN FUNCTION
--===============================================================================
  BEGIN
     hr_utility.set_location('Entering : '||l_proc, 10);
   ---------------------
   -- Set session date
   ---------------------

   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --
   hr_utility.set_location(l_proc, 20);
   ---------------------------
   -- Get Source Template ID
   ---------------------------
   l_source_template_id := get_template_id
                             (p_legislation_code  => 'GB'
                             );
   hr_utility.set_location(l_proc, 30);
   --
   /*--------------------------------------------------------------------------
      Create the user Structure
      The Configuration Flex segments for the Exclusion Rules are as follows:
    ---------------------------------------------------------------------------
    Config1  --
    Config2  --
   ---------------------------------------------------------------------------*/



   IF p_veh_type='C' THEN
    l_balfeed_excar :='N';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='Y';
    l_priv_car:='N';
    l_result:=NULL;
    l_lumpsum:='N';
    l_co_car:=NULL;
    l_sub:='Company';
    l_covan:='N';
    l_twowheel:='N';
    l_pedal:=NULL;
    l_excomp_id:='N';
   ELSIF p_veh_type='CM' THEN
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='N';
    l_balfeed_expc  :='Y';
    l_priv_car:='N';
    l_result:=NULL;
    l_lumpsum:='N';
    l_co_car:=NULL;
    l_sub:='Company';
    l_covan:='N';
    l_twowheel:='CM';
    l_pedal:=NULL;
    l_excomp_id:='N';
   ELSIF p_veh_type='CP' THEN
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='N';
    l_priv_car:='N';
    l_result:=NULL;
    l_lumpsum:='N';
    l_co_car:=NULL;
    l_sub:='Company';
    l_covan:='N';
    l_twowheel:='CP';
    l_pedal:='N';
    l_excomp_id:='N';
   ELSIF p_veh_type='P' THEN
    l_co_car:='N';
    l_priv_car :=NULL;
    l_result:=NULL;
    l_lumpsum:='N';
    l_sub:='Private';
    l_covan:='N';
    l_twowheel:='N';
    l_pedal:=NULL;
    l_balfeed_excar :='N';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='Y';
   ELSIF p_veh_type='PM' THEN
    l_co_car:='N';
    l_priv_car :=NULL;
    l_result:=NULL;
    l_lumpsum:='N';
    l_sub:='Private';
    l_covan:='N';
    l_twowheel:='PM';
    l_pedal:=NULL;
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='N';
    l_balfeed_expc  :='Y';
   ELSIF p_veh_type='PP' THEN
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='N';
    l_co_car:='N';
    l_priv_car :=NULL;
    l_result:=NULL;
    l_lumpsum:='N';
    l_sub:='Private';
    l_covan:='N';
    l_twowheel:='PP';
    l_pedal:='N';
   ELSIF p_veh_type='L' THEN

    l_pedal:='N';
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='N';
    l_co_car:='N';
    l_priv_car :='N';
    l_result:='N';
    l_lumpsum:=NULL;
    l_covan:='N';
  ELSIF p_veh_type='V' THEN

    l_pedal:='N';
    l_balfeed_excar :='Y';
    l_balfeed_exmc  :='Y';
    l_balfeed_expc  :='N';

    l_co_car:='N';
    l_priv_car :='N';
    l_result:='N';
    l_lumpsum:='N';
    l_covan:=NULL;
    l_sub:='Company Van';

  END IF;





  --
   -- create user structure from the template
   --
   pay_element_template_api.create_user_structure
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_business_group_id             =>     p_bg_id
    ,p_source_template_id            =>     l_source_template_id
    ,p_base_name                     =>     p_ele_name
    ,p_base_processing_priority      =>     p_ele_priority
    ,p_configuration_information1    =>     l_co_car
    ,p_configuration_information2    =>     l_priv_car
    ,p_configuration_information3    =>     l_lumpsum
    ,p_configuration_information4    =>     l_result
    ,p_configuration_information5    =>     l_covan
    ,p_configuration_information6    =>     l_twowheel
    ,p_configuration_information7    =>     l_pedal
    ,p_configuration_information8    =>     l_excomp_id
    ,p_configuration_information9    =>     l_balfeed_excar
    ,p_configuration_information10   =>     l_balfeed_exmc
    ,p_configuration_information11   =>     l_balfeed_expc
    ,p_template_id                   =>     l_template_id
    ,p_object_version_number         =>     l_object_version_number
    );
   --


   hr_utility.set_location(l_proc, 80);
   ---------------------------------------------------------------------------
   ---------------------------- Update Shadow Structure ----------------------
   --


   OPEN c1(p_ele_name||l_sub);
   LOOP
   FETCH c1 INTO l_element_type_id,l_ele_obj_ver_number;
   EXIT WHEN c1%NOTFOUND;

   pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
      ,p_effective_date              => p_ele_eff_start_date
      ,p_element_type_id             => l_element_type_id
      ,p_element_name                => p_ele_name
      ,p_description                 => p_ele_description
      ,p_reporting_name               =>p_ele_reporting_name
      ,p_object_version_number       => l_ele_obj_ver_number
     );



   END LOOP;
   OPEN c_input_id(l_element_type_id);
   LOOP
    FETCH c_input_id INTO l_ip_name,l_input_id,l_ip_object_version_number;
    EXIT WHEN c_input_id%NOTFOUND;
   IF  p_veh_type <>'P' OR p_veh_type <> 'C'
                  OR p_veh_type<>'L' OR p_veh_type <> 'V' THEN
    IF l_ip_name='Two Wheeler Type' THEN
    pay_siv_upd.upd(  p_effective_date         => p_ele_eff_start_date
                     ,p_input_value_id         => l_input_id
                     ,p_element_type_id        => l_element_type_id
                     ,p_default_value          => l_twowheel
                     ,p_object_version_number  => l_ip_object_version_number );
     END IF;

   END IF;

   IF  l_ip_name='User Rates Table'  THEN

-- The condition to check if the business group wants sliding rates table or
-- just a simple rates tables.
    IF p_table_indicator_flg = 'N' THEN
     pay_siv_upd.upd(  p_effective_date         => p_ele_eff_start_date
                      ,p_input_value_id         => l_input_id
                      ,p_element_type_id        => l_element_type_id
                      ,p_default_value          => p_table_name
                      ,p_object_version_number  => l_ip_object_version_number );
    ELSE
       pay_siv_upd.upd(  p_effective_date         => p_ele_eff_start_date
                      ,p_input_value_id         => l_input_id
                      ,p_element_type_id        => l_element_type_id
                      ,p_name                   => 'Sliding Rates Table'
                      ,p_default_value          => p_table_name
                      ,p_object_version_number  => l_ip_object_version_number );

    END IF;
   END IF;



    END LOOP;
    CLOSE c_input_id;
   CLOSE c1;



  IF p_veh_type='L' THEN
    l_lump(1):=' NIable LumpSum';
    l_lump(2):=' Direct LumpSum';


  FOR i in 1..l_lump.count
  LOOP
   OPEN c1(p_ele_name||l_lump(i));
    LOOP

   FETCH c1 INTO l_element_type_id,l_ele_obj_ver_number;
   EXIT WHEN c1%NOTFOUND;

    IF i=1 THEN
      l_lumptemp:=p_ele_name||' NIable';
    ELSE
      l_lumptemp:=p_ele_name||' Direct Payment';
    END IF;

   pay_shadow_element_api.update_shadow_element
     (p_validate                      => false
      ,p_effective_date               => p_ele_eff_start_date
      ,p_element_type_id              => l_element_type_id
      ,p_element_name                 => l_lumptemp
      ,p_object_version_number        => l_ele_obj_ver_number
     );

    END LOOP;
   CLOSE c1;
  END LOOP;
 END IF;






   -------------------------------------------------------------------------
   --





   hr_utility.set_location(l_proc, 90);
   --
   --
   hr_utility.set_location(l_proc, 110);
   ---------------------------------------------------------------------------
   ---------------------------- Generate Core Objects ------------------------
   ---------------------------------------------------------------------------

   pay_element_template_api.generate_part1
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_hr_only                       =>     false
    ,p_hr_to_payroll                 =>     false
    ,p_template_id                   =>     l_template_id);
   --
   hr_utility.set_location(l_proc, 120);
   --
   pay_element_template_api.generate_part2
    (p_validate                      =>     false
    ,p_effective_date                =>     p_ele_eff_start_date
    ,p_template_id                   =>     l_template_id);
   --

   hr_utility.set_location(l_proc, 130);

--IF p_veh_type='C' OR p_veh_type='P' THEN
   ---delete_balance_feeds('NIable','Pay Value');
   create_balance_feeds;
--END IF;

  --

   l_base_element_type_id := get_object_id ('ELE', p_ele_name);

--Update input values with the formula for validation

  IF p_veh_type='C' OR p_veh_type='P'
   OR p_veh_type='CP' OR p_veh_type='CM' OR p_veh_type='PP'
     OR p_veh_type='PM' THEN
     upd_inputval_formula(l_base_element_type_id
                           ,'Claim End Date'
                           ,'PQP_VALIDATE_DATE');
     upd_inputval_formula(l_base_element_type_id
                           ,'Purpose'
                           ,NULL);

  END IF;

  IF p_veh_type='P'  THEN
     upd_inputval_formula(l_base_element_type_id
                           ,'CO2 Emissions'
                           ,'CO2_EMISSIONS');

  END IF;

--  IF p_veh_type='L' OR p_veh_type='P' THEN
 --     upd_inputval_formula(l_base_element_type_id
  --                         ,'Table Name'
   --                       ,'PQP_VALIDATE_RATES_TABLE');

  --END IF;

  IF (p_veh_type='L' OR p_veh_type='P'OR p_veh_type='C') AND
       p_table_indicator_flg= 'N'   THEN
      upd_inputval_formula(l_base_element_type_id
                           ,'User Rates Table'
                          ,'PQP_VALIDATE_RATES_TABLE');
  ELSIF (p_veh_type='L' OR p_veh_type='P'OR p_veh_type='C') AND
       p_table_indicator_flg= 'Y'   THEN

    NULL;

  END IF;

    pay_element_extra_info_api.create_element_extra_info
                              (p_element_type_id            =>l_base_element_type_id
                              ,p_information_type           => 'PQP_VEHICLE_MILEAGE_INFO'
                              , P_EEI_INFORMATION_CATEGORY     =>'PQP_VEHICLE_MILEAGE_INFO'
                               ,p_eei_information1           => p_veh_type
                               ,p_eei_information2           => p_table_indicator_flg
                               ,p_eei_information3           => 'Y'
                              ,p_element_type_extra_info_id => l_eei_info_id
                              ,p_object_version_number      => l_ovn_eei);


 RETURN l_base_element_type_id;


  --
END create_user_template;
--
--
--==========================================================================
--                             Deletion procedure
--==========================================================================
--
PROCEDURE delete_user_template
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date        in date
           ) IS
  --
  l_template_id   NUMBER(9);
  l_proc   varchar2(60)      :='pay_uk_vehicle_template.delete_user_template';
  l_eei_info_id  number;
  l_ovn_eei   number;
  --
  CURSOR eei is
  SELECT element_type_extra_info_id
   FROM pay_element_type_extra_info petei
   WHERE element_type_id=p_ele_type_id ;


 CURSOR c1 is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_ele_name
    AND  business_group_id = p_business_group_id
    AND  template_type     = 'U';
--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);
   --
   OPEN eei;
    LOOP
    FETCH eei INTO l_eei_info_id  ;
    EXIT WHEN eei%NOTFOUND;


    pay_element_extra_info_api.delete_element_extra_info
                              (p_validate                    => FALSE
                               ,p_element_type_extra_info_id => l_eei_info_id
                              ,p_object_version_number       => l_ovn_eei);


      END LOOP;
     CLOSE eei;


   FOR c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   END LOOP;
   --

   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   --

   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
END delete_user_template;
--
END pqp_uk_vehicle_template ;


/
