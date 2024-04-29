--------------------------------------------------------
--  DDL for Package Body GL_AFF_AWC_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AFF_AWC_API_PKG" AS
/* $Header: gluafawb.pls 120.4 2005/11/09 23:32:08 spala noship $ */





  FUNCTION gl_coa_awc_rule(p_subscription_guid IN RAW,
                           p_event             IN OUT NOCOPY WF_EVENT_T)
    RETURN VARCHAR2 IS
    src_req_id         VARCHAR2(15);
    application_id     VARCHAR2(15);
    id_flex_code       VARCHAR2(10);
    id_flex_num        VARCHAR2(15);
    request_id         NUMBER;
  BEGIN
    FND_PROFILE.get('CONC_REQUEST_ID', src_req_id);

    -- only necessary when the event is raised directly from the form
    IF (to_number(src_req_id) <= 0) THEN

      application_id := p_event.GetValueForParameter('APPLICATION_ID');
      id_flex_code   := p_event.GetValueForParameter('ID_FLEX_CODE');
      id_flex_num    := p_event.GetValueForParameter('ID_FLEX_NUM');

      IF (application_id = '101' AND id_flex_code = 'GL#') THEN

        -- ################################################

        -- ADD CODE TO HANDLE TAGS AND CLAUSES TO UPDATE
        -- THE ADDITIONAL WHERE CLAUSE.......

        -- ################################################
        -- The delete call has been disbaled otherwise it is
        -- more unnecessary work to flex compiler.
        -- AOL team asked us to do this.
        --GL_AFF_AWC_API_PKG.GL_bs_delete_awc(id_flex_num, 'GL_BALANCING');
        GL_AFF_AWC_API_PKG.GL_bs_add_awc(id_flex_num, 'GL_BALANCING');

        IF (request_id = 0) THEN
          WF_CORE.CONTEXT('GL_COA_AWC_PKG', 'gl_coa_awc_rule',
                          p_event.getEventName, p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, FND_MESSAGE.get);
          return 'WARNING';
        END IF;

      END IF;

    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT('GL_COA_AWC_PKG', 'gl_coa_awc_rule',
                      p_event.getEventName, p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      return 'ERROR';
  END gl_coa_awc_rule;



  PROCEDURE  gl_bs_add_awc (coa_id IN NUMBER,
                            segment_type  IN VARCHAR2)
                                  IS

      l_flexfield          fnd_flex_key_api.flexfield_type;
      l_structure          fnd_flex_key_api.structure_type;
      l_segment            fnd_flex_key_api.segment_type;
      l_numof_awc_elements number;
      l_awc_elements       fnd_flex_key_api.awc_elements_type;
      l_found              boolean;
      l_segment_name       VARCHAR2(30);
      l_flex_value_type    VARCHAR2(1);
      l_tab_val_vs           NUMBER;
      l_flex_value_col_name  VARCHAR2(50);

  BEGIN
      fnd_flex_key_api.set_session_mode('seed_data');

      l_flexfield := fnd_flex_key_api.find_flexfield('SQLGL', 'GL#');

      l_structure := fnd_flex_key_api.find_structure(l_flexfield, coa_id);

     SELECT t1.segment_name, ffvs.validation_type, t1.flex_value_Set_id
      INTO   l_segment_name, l_flex_value_type, l_tab_val_vs
      FROM  fnd_id_flex_segments t1,
            fnd_segment_attribute_values t2,
            fnd_flex_value_sets ffvs
      WHERE t1.application_id          = t2.application_id
      AND   t1.id_flex_code            = t2.id_flex_code
      AND   t1.id_flex_num             = t2.id_flex_num
      AND   t1.application_column_name = t2.application_column_name
      AND   t1.application_id = 101
      AND   t1.id_flex_code = 'GL#'
      AND   t1.id_flex_num = coa_id
      AND   t1.enabled_flag = 'Y'
      AND   t2.segment_attribute_type = NVL(segment_type, 'GL_BALANCING')
      AND   t2.attribute_value = 'Y'
      AND   ffvs.flex_value_set_id = t1.flex_value_set_id;

      IF (l_flex_value_type = 'F') THEN

        SELECT  fvt.value_column_name
        INTO    l_flex_value_col_name
        FROM    FND_FLEX_VALIDATION_TABLES fvt
        WHERE   fvt.flex_value_set_id = l_tab_val_vs;

      END IF;



     l_segment :=

       fnd_flex_key_api.find_segment(l_flexfield, l_structure,l_segment_name);

      -- Get AWCs
      --
      fnd_flex_key_api.get_awc_elements(l_flexfield, l_structure, l_segment,
         l_numof_awc_elements, l_awc_elements);
      --
      -- Add a new AWC
      --
      l_found := false;
      FOR i in 1 .. l_numof_awc_elements LOOP
         IF (l_awc_elements(i).tag = 'GL_COA_BS_TAG') THEN
            l_found := TRUE;
            EXIT;
         END IF;
      END LOOP;

      IF (NOT l_found) THEN

       IF (l_flex_value_type <> 'F') THEN

           fnd_flex_key_api.add_awc(l_flexfield, l_structure, l_segment,
                             'GL_COA_BS_TAG',
                             'GL_AFF_AWC_API_PKG.'||
                             'gl_valid_flex_values(:$FLEX$.$VDATE$, '||
                               'FND_FLEX_VALUES_VL.Flex_Value) = ''Y''') ;


        ELSE

            fnd_flex_key_api.add_awc(l_flexfield, l_structure, l_segment,
                            'GL_COA_BS_TAG',
                            'GL_AFF_AWC_API_PKG.'||
                            'gl_valid_flex_values(:$FLEX$.$VDATE$,'
                            ||l_flex_value_col_name||') = ''Y''');

       END IF;
      END IF;

  END gl_bs_add_awc;


   FUNCTION  gl_valid_flex_values (p_valid_date   VARCHAR2,
                                   p_flex_value   VARCHAR2,
                                   p_id1          NUMBER DEFAULT NULL,
                                   p_char1        VARCHAR2 DEFAULT NULL,
                                   p_id2          NUMBER DEFAULT NULL,
                                   p_char2        VARCHAR2 DEFAULT NULL,
                                   p_id3          NUMBER DEFAULT NULL,
                                   p_char3        VARCHAR2 DEFAULT NULL)
              RETURN VARCHAR2 IS

    l_valid_value     VARCHAR2(1) ;
    l_lgr_id          NUMBER ;
    l_valid_date      DATE :=NULL;

  BEGIN

   If ((p_valid_date IS NOT NULL) AND (LENGTH(p_valid_date) >= 19)) THEN
      l_valid_date := TO_DATE(p_valid_date, 'YYYY/MM/DD HH24:MI:SS');
   ELSE
     l_valid_date := NULL;
   END IF;

   l_lgr_id := GL_GLOBAL.context_ledger_id;

    /* If the GL_GLOBAl package is not being called, then
       flex value validation should not be enforced and all BSV's are
       valid.
    */

     IF (l_lgr_id IS NULL or l_lgr_id = 0) Then

        Return 'Y';

     END IF;

      /* BSV's are not always assigned to ledgers. Therefore we should not
         enforce BSV assignemnt if there is no BSV flex value set
         is assigned to a ledger.
         IF bal_seg_value_option_code column value in GL_LEDGER table is
         'A' that means all BSV's are valid. If the column is 'I',
         then some BSV's are valid.

         To avoid multiple SQL checks GL_LEDGERS table is
         joined to gl_ledger_segment_values table.
      */

       SELECT  DECODE(NVL(gll.bal_seg_value_option_code, 'X'),
               'I',
               DECODE(glsv.segment_value, NULL, 'N',p_flex_value,'Y', 'N'),
               'Y')
       INTO    l_valid_value
       FROM    gl_ledger_segment_values glsv, gl_ledgers gll
       WHERE   gll.ledger_id = l_lgr_id
       AND     gll.ledger_id = glsv.ledger_id (+)
       AND     glsv.segment_type_code (+) = 'B'
       AND     NVL(glsv.status_code (+), 'X') <> 'I'
       AND     NVL(glsv.start_date (+),TO_DATE('1950/01/01','YYYY/MM/DD'))
                <= NVL(l_valid_date,TO_DATE('9999/12/31','YYYY/MM/DD'))
       AND     NVL(glsv.end_date (+),TO_DATE('9999/12/31','YYYY/MM/DD'))
                >= NVL(l_valid_date, TO_DATE('1950/01/01','YYYY/MM/DD'))
       AND     glsv.segment_value (+)  = p_flex_value;

    RETURN(l_valid_value);

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
        RETURN('N');
  END;

  PROCEDURE  gl_bs_delete_awc (coa_id IN NUMBER,
                               segment_type  IN VARCHAR2)
                                  IS

      l_flexfield          fnd_flex_key_api.flexfield_type;
      l_structure          fnd_flex_key_api.structure_type;
      l_segment            fnd_flex_key_api.segment_type;
      l_numof_awc_elements number;
      l_awc_elements       fnd_flex_key_api.awc_elements_type;
      l_found              boolean;
      l_segment_name       VARCHAR2(30);

  BEGIN
      fnd_flex_key_api.set_session_mode('seed_data');

      l_flexfield := fnd_flex_key_api.find_flexfield('SQLGL', 'GL#');

      l_structure := fnd_flex_key_api.find_structure(l_flexfield, coa_id);

     SELECT t1.segment_name
      INTO   l_segment_name
      FROM  fnd_id_flex_segments t1,
            fnd_segment_attribute_values t2,
            fnd_flex_value_sets ffvs
      WHERE t1.application_id          = t2.application_id
      AND   t1.id_flex_code            = t2.id_flex_code
      AND   t1.id_flex_num             = t2.id_flex_num
      AND   t1.application_column_name = t2.application_column_name
      AND   t1.application_id = 101
      AND   t1.id_flex_code = 'GL#'
      AND   t1.id_flex_num = coa_id
      AND   t1.enabled_flag = 'Y'
      AND   t2.segment_attribute_type = NVL(segment_type, 'GL_BALANCING')
      AND   t2.attribute_value = 'Y'
      AND   ffvs.flex_value_set_id = t1.flex_value_set_id;

     l_segment :=
       fnd_flex_key_api.find_segment(l_flexfield, l_structure,l_segment_name);

      -- Get AWCs
      --
      fnd_flex_key_api.get_awc_elements(l_flexfield, l_structure, l_segment,
         l_numof_awc_elements, l_awc_elements);

       --
      -- Delete an old AWC
      --
      l_found := false;
      FOR i in 1 .. l_numof_awc_elements LOOP
         IF (l_awc_elements(i).tag = 'GL_COA_BS_TAG') THEN
            l_found := TRUE;
            EXIT;
         END IF;
      END LOOP;

      IF (l_found) THEN
         fnd_flex_key_api.delete_awc(l_flexfield, l_structure, l_segment,
            'GL_COA_BS_TAG');
      END IF;

  END gl_bs_delete_awc;

 --**************************************************************

END GL_AFF_AWC_API_PKG;

/
