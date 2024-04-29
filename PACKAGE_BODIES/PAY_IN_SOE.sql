--------------------------------------------------------
--  DDL for Package Body PAY_IN_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_SOE" AS
/* $Header: pyinsoe.pkb 120.7.12010000.14 2010/03/03 09:53:13 mdubasi ship $ */
  TYPE clob_tab_type IS TABLE OF CLOB INDEX BY BINARY_INTEGER;

  g_clob              clob_tab_type;
  g_tmp_clob          CLOB;
  g_clob_cnt          NUMBER;
  g_fetch_clob_cnt    NUMBER;
  g_chunk_size        NUMBER;
  g_business_group_id NUMBER;
  g_package     CONSTANT VARCHAR2(100) := 'pay_in_soe.';
  g_debug       BOOLEAN;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_TEMPLATE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure gets the payslip template code set at--
  --                  organization level.If no template is set default    --
  --                  template code is returned                           --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id    NUMBER                       --
  --            OUT : p_template             VARCHAR2                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_template (
                          p_business_group_id    IN NUMBER
                         ,p_template             OUT NOCOPY VARCHAR2
                         )
  IS
  --
    CURSOR csr_payslip_info
    IS
    --
      SELECT org_information7 template
            ,org_information8 chunk_size
      FROM   hr_organization_information_v
      WHERE organization_id        = p_business_group_id
      AND   org_information_context= 'PER_IN_PRINTED_PAYSLIP';
    --
    l_template   VARCHAR2(50);
    l_chunk_size NUMBER;
    l_procedure   VARCHAR(100);
    l_message     VARCHAR2(250);

  --
  BEGIN
  --
    l_procedure := g_package || 'get_template';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_business_group_id',p_business_group_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;



    OPEN csr_payslip_info;
    FETCH csr_payslip_info
      INTO l_template
          ,l_chunk_size;

	-- If Organization level payslip information does not exists return default
	-- Else return the information set
    IF (csr_payslip_info%NOTFOUND) THEN
    --
      p_template   := 'PAY_IN_PAYSLIP_TEMPLATE';
      g_chunk_size := 500;
    --
    ELSE
    --
    pay_in_utils.trace('l_template ',l_template);
    pay_in_utils.set_location(g_debug,l_procedure,20);
    pay_in_utils.trace('g_chunk_size ',g_chunk_size);
    pay_in_utils.set_location(g_debug,l_procedure,30);

      p_template   := l_template;
      g_chunk_size := l_chunk_size;
    --
    END IF;
  --
   IF g_debug THEN
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.trace('p_template',p_template);
   pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    EXCEPTION
      WHEN OTHERS THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_payslip_info%ISOPEN THEN
        CLOSE csr_payslip_info;
      END IF;
    RAISE;
    --
  --
  END get_template;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_TAG                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure appends a given tag and value to     --
  --                  g_tmp_clob                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_tag_name          VARCHAR2                        --
  --            OUT : p_value             VARCHAR2                        --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_tag(p_tag_name VARCHAR2
                      ,p_value    VARCHAR2)
  IS
  --
    l_str        VARCHAR2(400);
    l_procedure   VARCHAR(100);
    l_message     VARCHAR2(250);
  --
  BEGIN
  --
   l_procedure := g_package || 'append_tag';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_tag_name',p_tag_name);
      pay_in_utils.trace('p_value',p_value);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

    /*Bug 4070869 - Encoded the data*/
    l_str:= '<'||p_tag_name||'>'||pay_in_utils.ENCODE_HTML_STRING(p_value)||'</'||p_tag_name||'>';

    pay_in_utils.trace('l_str ',l_str);
    pay_in_utils.set_location(g_debug,l_procedure,20);

    dbms_lob.writeAppend(g_tmp_clob,length(l_str),l_str);

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

  END append_tag;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : OPEN_TAG                                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure appends a open tag to g_tmp_clob     --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_tag_name             VARCHAR2                     --
  --------------------------------------------------------------------------
  --
  PROCEDURE open_tag(p_tag_name VARCHAR2)
  IS
  --
    l_str        VARCHAR2(250);
    l_procedure   VARCHAR(100);
    l_message     VARCHAR2(250);

  --
  BEGIN
  --
    l_procedure := g_package || 'open_tag';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_tag_name',p_tag_name);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

    l_str:= '<'||p_tag_name||'>';
    dbms_lob.writeAppend(g_tmp_clob,length(l_str),l_str);

    pay_in_utils.trace('l_str ',l_str);
    pay_in_utils.set_location(g_debug,l_procedure,20);

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

  END open_tag;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CLOSE_TAG                                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure appends a close tag to g_tmp_clob    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_tag_name             VARCHAR2                     --
  --------------------------------------------------------------------------
  --
  PROCEDURE close_tag(p_tag_name VARCHAR2)
  IS
  --
    l_str       VARCHAR2(250);
    l_procedure   VARCHAR(100);
    l_message     VARCHAR2(250);

  --
  BEGIN
  --
   l_procedure := g_package || 'close_tag';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_tag_name',p_tag_name);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

    l_str:= '</'||p_tag_name||'>';
    dbms_lob.writeAppend(g_tmp_clob,length(l_str),l_str);

    pay_in_utils.trace('l_str ',l_str);
    pay_in_utils.set_location(g_debug,l_procedure,20);

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

  END close_tag;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : SUBMIT_REQ_XML_BURST                                --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                             --
  -- Description    : This function submits the CP XDOBURSTREP to burst   --
  --                  XML                                                 --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_request_id          NUMBER                        --
  --------------------------------------------------------------------------
  --
  PROCEDURE submit_req_xml_burst(p_request_id IN NUMBER)
  IS
  --
   l_req_id              NUMBER := 0;
   l_set_layout          BOOLEAN;
   l_procedure           VARCHAR2(100);
   l_message             VARCHAR2(250);
   l_product_release     VARCHAR2(50);
  --
  BEGIN
  --
   l_procedure := g_package || 'submit_req_xml_burst';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_request_id',TO_CHAR(p_request_id));
      pay_in_utils.trace('**************************************************','********************');
   END IF;

    UPDATE fnd_concurrent_requests
    SET    output_file_type = 'XML'
    WHERE  request_id = p_request_id;

    COMMIT ;

    SELECT substr(p.product_version,1,2) INTO l_product_release
      FROM fnd_application a, fnd_application_tl t, fnd_product_installations p
     WHERE a.application_id = p.application_id
       AND a.application_id = t.application_id
       AND t.language = Userenv ('LANG')
       AND Substr (a.application_short_name, 1, 5) = 'PAY';

    l_set_layout := fnd_request.add_layout('XDO','BURST_STATUS_REPORT','en','US','PDF');

   /* The CP definition for 11i and R12 is different. So pass correct number of parameters
      for 11i and R12 accordingly */
    IF TO_NUMBER(l_product_release) = 11 THEN
    l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOBURSTREP',NULL,NULL,FALSE,p_request_id,'N');
    ELSE
    l_req_id := FND_REQUEST.SUBMIT_REQUEST('XDO','XDOBURSTREP',NULL,NULL,FALSE,'Y',p_request_id,'N');
    END IF;


  END submit_req_xml_burst;

  --------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ADDRESS_DETAILS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This procedure gets the employee address details    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         per_addresses.address_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_address_details ( p_address_id   IN   per_addresses.address_id%TYPE
                             , p_concatenate  IN   VARCHAR2     DEFAULT 'N'
                             , p_field        IN   VARCHAR2     DEFAULT NULL
                       )
RETURN VARCHAR2
IS

  CURSOR csr_get_address_details
  IS
    SELECT pad.address_line1
         , pad.address_line2
         , pad.address_line3
         , pad.add_information13
         , pad.add_information14
         , hr_general.decode_lookup('IN_STATES',pad.add_information15)
         , hr_general.decode_lookup('PER_US_COUNTRY_CODE',pad.country)
         , pad.postal_code
      FROM per_addresses pad
     WHERE pad.address_id            = p_address_id;

  l_procedure          VARCHAR2(100);
  l_location_address1  hr_locations.address_line_1%TYPE;
  l_location_address2  hr_locations.address_line_2%TYPE;
  l_location_address3  hr_locations.address_line_3%TYPE;
  l_location_address4  hr_locations.loc_information14%TYPE;
  l_location_city      hr_locations.loc_information15%TYPE;
  l_location_state     hr_locations.loc_information16%TYPE;
  l_location_country   hr_locations.country%TYPE;
  l_location_zipcode   hr_locations.postal_code%TYPE;
  l_details            VARCHAR2(1000);

  BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'get_location_details';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_address_id ',p_address_id );
	pay_in_utils.trace('p_concatenate',p_concatenate);
	pay_in_utils.trace('p_field'  ,p_field      );
	pay_in_utils.trace('**************************************************','********************');
   END IF;

  OPEN  csr_get_address_details;
  FETCH csr_get_address_details
   INTO l_location_address1
      , l_location_address2
      , l_location_address3
      , l_location_address4
      , l_location_city
      , l_location_state
      , l_location_country
      , l_location_zipcode;
  CLOSE csr_get_address_details;

  IF p_concatenate = 'Y' THEN
     SELECT l_location_address1   || DECODE(l_location_address1,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address2   || DECODE(l_location_address2,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address3   || DECODE(l_location_address3,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address4   || DECODE(l_location_address4,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_city       || DECODE(l_location_city    ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_state      || DECODE(l_location_state   ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_zipcode    || DECODE(l_location_zipcode ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_country
 INTO l_details
 FROM DUAL;

  ELSIF p_field = 'ADDRESS1' THEN
     l_details := l_location_address1;
  ELSIF p_field = 'ADDRESS2' THEN
     l_details := l_location_address2;
  ELSIF p_field = 'ADDRESS3' THEN
     l_details := l_location_address3;
  ELSIF p_field = 'ADDRESS4' THEN
     l_details := l_location_address4;
  ELSIF p_field = 'CITY' THEN
     l_details := l_location_city;
  ELSIF p_field = 'STATE' THEN
     l_details := l_location_state;
  ELSIF p_field = 'POSTAL_CODE' THEN
     l_details := l_location_zipcode;
  ELSIF p_field = 'COUNTRY' THEN
     l_details := l_location_country;
  END IF;

  l_details :=RTRIM(l_details,','||fnd_global.local_chr(10));



 IF g_debug THEN
     pay_in_utils.trace('l_details',l_details);
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
 RETURN l_details;

END get_address_details;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EMP_ADDRESS                                     --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns Emp Address                   --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_person_id           NUMBER                        --
  --             IN : p_date                DATE                          --
  --------------------------------------------------------------------------
  --
  FUNCTION get_emp_address(p_person_id     NUMBER
                           ,p_date          DATE   )
  RETURN VARCHAR2 IS
  --
   l_procedure           VARCHAR2(100);
   l_message             VARCHAR2(250);
   l_emp_addr            VARCHAR2(500) := NULL ;
   l_emp_addr_id         per_addresses.address_id%TYPE ;

   CURSOR c_employee_address
   IS
   SELECT pa.address_id
   FROM   per_addresses pa
   WHERE  pa.person_id = p_person_id
   AND    pa.address_type = DECODE(pa.address_type,'IN_P','IN_P','IN_C')
   AND    TO_DATE(p_date) BETWEEN pa.date_from AND nvl(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'))
   ORDER BY address_type DESC;

  --
  BEGIN
  --
   l_procedure := g_package || 'get_emp_address';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id',TO_CHAR(p_person_id));
      pay_in_utils.trace('p_date     ',TO_CHAR(p_date));
      pay_in_utils.trace('**************************************************','********************');
   END IF;

    OPEN c_employee_address;
    FETCH c_employee_address INTO l_emp_addr_id ;
    CLOSE c_employee_address ;


    l_emp_addr := get_address_details(l_emp_addr_id,'Y','NULL');

    pay_in_utils.set_location(g_debug,'l_emp_addr: '||l_emp_addr,10);
    RETURN l_emp_addr;

  END get_emp_address;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EMP_EMAIL                                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This function returns Employee Email Id             --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assign_action_id    NUMBER                        --
  --------------------------------------------------------------------------

  FUNCTION get_emp_email(p_assign_action_id NUMBER)
  RETURN VARCHAR2 IS
  l_procedure           VARCHAR2(100);
  l_message             VARCHAR2(250);
  l_emp_email_id        per_people_f.email_address%TYPE;

  CURSOR c_emp_email_id
  IS
  SELECT pai.action_information1
   FROM  pay_action_information pai
   WHERE action_information_category = 'IN_EMPLOYEE_DETAILS'
   AND action_context_id = p_assign_action_id;

  --
  BEGIN
  --
   l_procedure := g_package || 'get_emp_email';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assign_action_id',TO_CHAR(p_assign_action_id));
      pay_in_utils.trace('**************************************************','********************');
   END IF;

    OPEN c_emp_email_id;
    FETCH c_emp_email_id INTO l_emp_email_id ;

    IF c_emp_email_id%NOTFOUND THEN
    l_emp_email_id := '';
    pay_in_utils.set_location(g_debug,l_procedure,20);
    END IF;
    CLOSE c_emp_email_id;

    RETURN l_emp_email_id;

   END get_emp_email;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_ELEMENTS                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets archive elements of the given   --
  --                  classification name and append them to g_tmp_clob   --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --            OUT : p_classification_name  VARCHAR2                     --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_elements(
                             p_action_context_id    IN NUMBER
                            ,p_classification_name  IN VARCHAR2
                           )
  IS
  --
    CURSOR csr_elements_earnings
    IS
    --
    SELECT  DECODE(element_classification
                  ,'Earnings', element_reporting_name
                  ,'Paid Monetary Perquisite', SUBSTR(element_reporting_name, 0,
                                               LENGTH(element_reporting_name) - 8)) ename
           ,current_amount         amt
    FROM  pay_apac_payslip_elements_v
    WHERE action_context_id      = p_action_context_id
    AND   (element_classification = p_classification_name
        OR element_classification = 'Paid Monetary Perquisite');

    CURSOR csr_elements
    IS
    --
    SELECT  element_reporting_name ename
           ,current_amount         amt
    FROM  pay_apac_payslip_elements_v
    WHERE action_context_id      = p_action_context_id
    AND   element_classification = p_classification_name;

    l_total               NUMBER;
    l_rec_exists          BOOLEAN;
    l_classification_tag  VARCHAR2(100);
    l_procedure           VARCHAR2(100);
    l_message             VARCHAR2(250);
  --
  BEGIN
  --
   l_procedure := g_package || 'append_elements';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_action_context_id',p_action_context_id);
      pay_in_utils.trace ('p_classification_name',p_classification_name);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;


    l_total := 0;
    l_rec_exists := FALSE;
    IF p_classification_name = 'Employer Charges' THEN
    --
      l_classification_tag  := 'ERCharges';
    ELSIF p_classification_name = 'Fringe Benefits' THEN
    --
      l_classification_tag  := 'FringeBenefits';

    --
    ELSE
    --
      l_classification_tag  := p_classification_name;
    --
    END IF;
    open_tag(l_classification_tag);

    pay_in_utils.trace('l_classification_tag ',l_classification_tag);
    pay_in_utils.set_location(g_debug,l_procedure,20);

    IF (l_classification_tag = 'Earnings') THEN
        FOR rec in csr_elements_earnings
        LOOP
        --
            l_rec_exists := TRUE;
            open_tag(l_classification_tag || 'Element');

            pay_in_utils.trace('Element Name : ',rec.ename);
            pay_in_utils.set_location(g_debug,l_procedure,30);
            pay_in_utils.trace('This Pay : ',rec.amt);
            pay_in_utils.set_location(g_debug,l_procedure,40);

            append_tag('Description',rec.ename);
            append_tag('Amount',pay_us_employee_payslip_web.get_format_value(
                                     g_business_group_id
                                    ,rec.amt));

            close_tag(l_classification_tag || 'Element');
            l_total := l_total + rec.amt;
        --
        END LOOP;

    ELSE
        FOR rec in csr_elements
        LOOP
            --
            l_rec_exists := TRUE;
            open_tag(l_classification_tag || 'Element');

            pay_in_utils.trace('Element Name : ',rec.ename);
            pay_in_utils.set_location(g_debug,l_procedure,30);
            pay_in_utils.trace('This Pay : ',rec.amt);
            pay_in_utils.set_location(g_debug,l_procedure,40);

            append_tag('Description',rec.ename);
            append_tag('Amount',pay_us_employee_payslip_web.get_format_value(
                                     g_business_group_id
                                    ,rec.amt));

            close_tag(l_classification_tag || 'Element');
            l_total := l_total + rec.amt;
            --
        END LOOP;
    END IF;

      pay_in_utils.trace('l_total : ',l_total);
      pay_in_utils.set_location(g_debug,l_procedure,50);

    IF l_rec_exists = FALSE THEN
    --
      open_tag(l_classification_tag|| 'Element');

      append_tag('Description','No data exists');
      append_tag('Amount','');

      close_tag(l_classification_tag || 'Element');
    --
    END IF;

    append_tag(l_classification_tag || 'Total',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,l_total));

    close_tag(l_classification_tag);


   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

    EXCEPTION
      WHEN others THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_elements%ISOPEN THEN
        CLOSE csr_elements;
      END IF;
      RAISE;
  --
  END append_elements;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_NET_PAY                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets net pay                         --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_net_pay(
                            p_action_context_id  IN NUMBER
                          )
  IS
  --
    CURSOR csr_sum_amt(p_classification_name VARCHAR2)
    IS
    --
    SELECT  sum(current_amount) amt
    FROM  pay_apac_payslip_elements_v
    WHERE action_context_id      = p_action_context_id
    AND   element_classification = p_classification_name;

    l_gross_earnings    NUMBER;
    l_gross_deductions  NUMBER;
    l_advances		NUMBER;
    l_fbenefits		NUMBER;
    l_mon_perks         NUMBER;
    l_net_pay           NUMBER;
    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
  --
  BEGIN
  --
   l_procedure := g_package || 'append_net_pay';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace (' p_action_context_id', p_action_context_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;


    open_tag('NetPay');

    OPEN csr_sum_amt('Earnings');
    FETCH csr_sum_amt
      INTO l_gross_earnings;
    CLOSE csr_sum_amt;

    OPEN csr_sum_amt('Advances');
    FETCH csr_sum_amt
      INTO l_advances;
    CLOSE csr_sum_amt;

    OPEN csr_sum_amt('Fringe Benefits');
    FETCH csr_sum_amt
      INTO l_fbenefits;
    CLOSE csr_sum_amt;

    OPEN csr_sum_amt('Paid Monetary Perquisite');
    FETCH csr_sum_amt
      INTO l_mon_perks;
    CLOSE csr_sum_amt;

    l_gross_earnings := l_gross_earnings + NVL(l_advances,0)+ NVL(l_fbenefits,0) + NVL(l_mon_perks,0);

    pay_in_utils.trace('l_gross_earnings : ',l_gross_earnings);
    pay_in_utils.set_location(g_debug,l_procedure,20);

    append_tag('GrossEarnings',pay_us_employee_payslip_web.get_format_value(
                                 g_business_group_id
                                ,l_gross_earnings));


    OPEN csr_sum_amt('Deductions');
    FETCH csr_sum_amt
      INTO l_gross_deductions;
    CLOSE csr_sum_amt;

    l_gross_deductions := NVL(l_gross_deductions,0);
    pay_in_utils.trace('l_gross_deductions ',l_gross_deductions);
    pay_in_utils.set_location(g_debug,l_procedure,30);

    append_tag('GrossDeductions',pay_us_employee_payslip_web.get_format_value(
                                    g_business_group_id
                                   ,l_gross_deductions));

    l_net_pay:=l_gross_earnings - l_gross_deductions;

    pay_in_utils.trace('l_net_pay ',l_net_pay);
    pay_in_utils.set_location(g_debug,l_procedure,30);

    append_tag('Pay',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,l_net_pay));


    close_tag('NetPay');

  --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    EXCEPTION
      WHEN others THEN
         l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
         pay_in_utils.trace(l_message,l_procedure);

      IF csr_sum_amt%ISOPEN THEN
        CLOSE csr_sum_amt;
      END IF;
      RAISE;
  --
  END append_net_pay;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_BALANCES                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets the balances                    --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_balances(
                             p_action_context_id  IN NUMBER
                           )
  IS
  --
    CURSOR csr_balances
    IS
    --
    SELECT narrative bname
          ,ytd_amount ytd
    FROM  pay_apac_payslip_balances_v
    WHERE action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
  --
  BEGIN
  --
    l_procedure := g_package ||'append_balances';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_action_context_id',p_action_context_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;


    open_tag('Balances');

    FOR rec in csr_balances
    LOOP
    --
      open_tag('Balance');

      pay_in_utils.trace('Balance Name : ',rec.bname);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('YTD : ',rec.ytd);
      pay_in_utils.set_location(g_debug,l_procedure,30);

      append_tag('Description',rec.bname);
      append_tag('YTD',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.ytd));

      close_tag('Balance');
    --
    END LOOP;

    close_tag('Balances');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    EXCEPTION
      WHEN others THEN
         l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
         pay_in_utils.trace(l_message,l_procedure);

      IF csr_balances%ISOPEN THEN
         CLOSE csr_balances;
      END IF;
      RAISE;
  --
  END append_balances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_OTHER_ELEMENTS                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets EMEA element                    --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_other_elements(
                                   p_action_context_id  IN NUMBER
                                 )
  IS
  --
    CURSOR csr_other_elements
    IS
    --
    SELECT  narrative
           ,amount
    FROM   pay_emea_usr_ele_action_info_v
    WHERE  action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
    l_rec_exists        BOOLEAN;
    num_char            EXCEPTION ;
    PRAGMA EXCEPTION_INIT(num_char,-06502);
  --
  BEGIN
  --
   l_rec_exists := FALSE;
   l_procedure := g_package ||'append_other_elements';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_action_context_id',p_action_context_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

    open_tag('EMEAElements');

    FOR rec in csr_other_elements
    LOOP
    --
      l_rec_exists := TRUE;
      open_tag('EMEAElement');


      pay_in_utils.trace('Element Name : ',rec.narrative);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('Value : ',rec.amount);
      pay_in_utils.set_location(g_debug,l_procedure,30);

      append_tag('Description',rec.narrative);

      BEGIN
         append_tag('Value',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.amount));
      EXCEPTION
      WHEN num_char THEN
         append_tag('Value',rec.amount);
      END ;

      close_tag('EMEAElement');
    --
    END LOOP;

    IF l_rec_exists = FALSE THEN
    --
      open_tag('EMEAElement');

      append_tag('Description','No Data Exists.');
      append_tag('Value','');

      close_tag('EMEAElement');
    --
    END IF;
    close_tag('EMEAElements');

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    EXCEPTION
      WHEN OTHERS THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_other_elements%ISOPEN THEN
          CLOSE csr_other_elements;
      END IF;
      RAISE;

  END append_other_elements;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_ACCRUALS                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets accruals                        --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_accruals(
                             p_action_context_id  IN NUMBER
                           )
  IS
  --
    CURSOR csr_accruals
    IS
    --
      SELECT accrual_plan_name plan_name
            ,uom
            ,balance
      FROM   pay_apac_payslip_accruals_v
      WHERE  action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
    l_rec_exists        BOOLEAN;
  --
  BEGIN
  --
    l_procedure := g_package ||'append_accruals';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_action_context_id',p_action_context_id);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

    l_rec_exists := FALSE;
    open_tag('Accruals');

    FOR rec in csr_accruals
    LOOP
    --
      l_rec_exists := TRUE;
      open_tag('AccrualPlan');

      pay_in_utils.trace('Plan Name : ',rec.plan_name);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('UOM  : ',rec.uom);
      pay_in_utils.set_location(g_debug,l_procedure,30);
      pay_in_utils.trace('Accrual Balance : ',rec.balance);
      pay_in_utils.set_location(g_debug,l_procedure,40);

      /* Bug 4218967 Changed the tag AccrBalance to Balance */
      append_tag('PlanName',rec.plan_name);
      append_tag('UOM',rec.uom);
      append_tag('Balance',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.balance));

      close_tag('AccrualPlan');
    --
    END LOOP;

    IF l_rec_exists = FALSE THEN
    --
      open_tag('AccrualPlan');

      append_tag('PlanName','No data exists.');
      append_tag('UOM','');
      append_tag('AccrBalance','');

      close_tag('AccrualPlan');
    --
    END IF;
    close_tag('Accruals');

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

    EXCEPTION
      WHEN others THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_accruals%ISOPEN THEN
        CLOSE csr_accruals;
      END IF;
      RAISE;
  --
  END append_accruals;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_ABSENCES                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets absences                        --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_absences(
                             p_action_context_id  IN NUMBER
                           )
  IS
  --
    CURSOR csr_absences
    IS
    --
      SELECT absence_type absence_name
            ,start_date
            ,end_date
            ,absence_value
      FROM pay_apac_payslip_absences_v
      WHERE action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
    l_rec_exists        BOOLEAN;
  --
  BEGIN
  --
    l_procedure := g_package || 'append_absences';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace ('**************************************************','********************');
       pay_in_utils.trace ('p_action_context_id',p_action_context_id);
       pay_in_utils.trace ('**************************************************','********************');
    END IF;

    l_rec_exists := FALSE;
    open_tag('Absences');

    FOR rec in csr_absences
    LOOP
    --
      l_rec_exists := TRUE;
      open_tag('Absence');

      pay_in_utils.trace('Absence Name : ',rec.absence_name);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('Start Date  : ',to_char(rec.start_date,'DD-MON-YYYY'));
      pay_in_utils.set_location(g_debug,l_procedure,30);
      pay_in_utils.trace('End Date : ',to_char(rec.end_date,'DD-MON-YYYY'));
      pay_in_utils.set_location(g_debug,l_procedure,40);
      pay_in_utils.trace('This Pay : ',rec.absence_value);
      pay_in_utils.set_location(g_debug,l_procedure,50);

      append_tag('AbsenceName',rec.absence_name);
      append_tag('StartDate',to_char(rec.start_date,'DD-MON-YYYY'));
      append_tag('EndDate',to_char(rec.end_date,'DD-MON-YYYY'));
      append_tag('ThisPay',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.absence_value));

      close_tag('Absence');
    --
    END LOOP;

    IF l_rec_exists = FALSE THEN
    --
      open_tag('Absence');

      append_tag('AbsenceName','No data exists.');
      append_tag('StartDate','');
      append_tag('EndDate','');
      append_tag('ThisPay','');

      close_tag('Absence');
    --
    END IF;
    close_tag('Absences');

  --
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

    EXCEPTION
      WHEN others THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_absences%ISOPEN THEN
         CLOSE csr_absences;
      END IF;
      RAISE;
  --
  END append_absences;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_MESSAGES                                     --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets messages                        --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_messages(
                             p_action_context_id  IN NUMBER
                           )
  IS
  --
    CURSOR csr_messages
    IS
    --

    SELECT pai.action_information6 value
    FROM pay_assignment_actions paa, pay_action_information pai
    WHERE paa.assignment_action_id = p_action_context_id
    AND paa.payroll_action_id = pai.action_context_id
    AND pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'
    AND pai.action_information2 = 'MESG'
    AND pai.jurisdiction_code IS NOT NULL
    UNION
    SELECT pai.action_information6 value
    FROM pay_action_information pai,pay_assignment_actions paa
    WHERE paa.assignment_action_id = p_action_context_id
    AND pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'
    AND pai.action_information2 = 'MESG'
    AND paa.payroll_action_id = pai.action_context_id
    AND paa.assignment_id = nvl(pai.assignment_id,paa.assignment_id)
    AND EXISTS
      (SELECT ppa1.pay_advice_message
      FROM pay_assignment_actions paa1,pay_action_interlocks intl,pay_payroll_actions ppa1
      WHERE intl.locking_action_id = paa.assignment_action_id
      AND intl.locked_action_id = paa1.assignment_action_id
      AND paa1.payroll_action_id = ppa1.payroll_action_id
      AND ppa1.pay_advice_message IS NOT NULL
      AND ppa1.action_type IN('R','Q'));

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
  --
  BEGIN

    l_procedure := g_package || 'append_messages';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_action_context_id',p_action_context_id);
       pay_in_utils.trace('**************************************************','********************');
    END IF;


    open_tag('Messages');
    FOR rec in csr_messages
    LOOP
    --
      open_tag('Mesg');

      pay_in_utils.trace('Mesg  : ',rec.value);
      pay_in_utils.set_location(g_debug,l_procedure,20);

      append_tag('Value',rec.value);

      close_tag('Mesg');
    --
    END LOOP;
    close_tag('Messages');

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

    EXCEPTION
      WHEN OTHERS THEN
         l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
         pay_in_utils.trace(l_message,l_procedure);

      IF csr_messages%ISOPEN THEN
        CLOSE csr_messages;
      END IF;
      RAISE;
  --
  END append_messages;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_OTHER_BALANCES                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets EMEA Elements                   --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_other_balances(
                                   p_action_context_id  IN NUMBER
                                 )
  IS
  --
    CURSOR csr_other_balances
    IS
    --
    SELECT  narrative
           ,value
    FROM   pay_apac_bals_action_info_v
    WHERE  action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
    l_rec_exists        BOOLEAN;
  --
  BEGIN
  --
    l_procedure := g_package || 'append_other_balances';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_action_context_id',p_action_context_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

    l_rec_exists := FALSE;
    open_tag('EMEABalances');

    FOR rec in csr_other_balances
    LOOP
    --
      l_rec_exists := TRUE;
      open_tag('EMEABalance');

      pay_in_utils.trace('Description  : ',rec.narrative);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('Amount : ',rec.value);
      pay_in_utils.set_location(g_debug,l_procedure,30);


      append_tag('Description',rec.narrative);
      append_tag('Amount',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.value));

      close_tag('EMEABalance');
    --
    END LOOP;

    IF l_rec_exists = FALSE THEN
    --
      open_tag('EMEABalance');

      append_tag('Description','No data exists.');
      append_tag('Amount','');

      close_tag('EMEABalance');
    --
    END IF;
    close_tag('EMEABalances');

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

    EXCEPTION
      WHEN OTHERS THEN
         l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
         pay_in_utils.trace(l_message,l_procedure);

      IF csr_other_balances%ISOPEN THEN
        CLOSE csr_other_balances;
      END IF;
      RAISE;
  --
  END append_other_balances;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : APPEND_PAYMENT_DETAILS                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets Payment Details                 --
  --                  and appends them to g_tmp_clob                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_action_context_id    NUMBER                       --
  --------------------------------------------------------------------------
  --
  PROCEDURE append_payment_details(
                                    p_action_context_id  IN NUMBER
                                  )
  IS
  --
    CURSOR csr_payment_details
    IS
    --
    SELECT org_payment_method_name payment_method
          ,segment1                bank_name
          ,segment3                account_number
          ,value
    FROM pay_emp_net_dist_action_info_v pendv
    WHERE pendv.action_context_id = p_action_context_id;

    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
    l_rec_exists        BOOLEAN;
  --
  BEGIN
  --
    l_procedure := g_package ||'append_payment_details';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
       pay_in_utils.trace ('**************************************************','********************');
       pay_in_utils.trace ('p_action_context_id',p_action_context_id);
       pay_in_utils.trace ('**************************************************','********************');
    END IF;

    l_rec_exists := FALSE;
    open_tag('PaymentDetails');

    FOR rec in csr_payment_details
    LOOP
    --
      l_rec_exists := TRUE;
      open_tag('Payment');

      pay_in_utils.trace('Payment Method   : ',rec.payment_method);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('Bank Name  : ',rec.bank_name);
      pay_in_utils.set_location(g_debug,l_procedure,30);
      pay_in_utils.trace('Account Number  : ',rec.account_number);
      pay_in_utils.set_location(g_debug,l_procedure,40);
      pay_in_utils.trace('This Pay   : ',rec.value);
      pay_in_utils.set_location(g_debug,l_procedure,50);

      append_tag('PaymentType',rec.payment_method);
      append_tag('Bank',rec.bank_name);
      append_tag('AccountNumber',rec.account_number);
      append_tag('Amount',pay_us_employee_payslip_web.get_format_value(
                               g_business_group_id
                              ,rec.value));

      close_tag('Payment');
    --
    END LOOP;

    IF l_rec_exists = FALSE THEN  /*Added for bug#7383091 */
    --
      open_tag('Payment');

      append_tag('PaymentType','No Data Exists.');
      append_tag('Bank','');
      append_tag('AccountNumber','');
      append_tag('Amount','');

      close_tag('Payment');
    --
    END IF;
    close_tag('PaymentDetails');

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

    EXCEPTION
      WHEN others THEN
         l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
         pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
         pay_in_utils.trace(l_message,l_procedure);

      IF csr_payment_details%ISOPEN THEN
          CLOSE csr_payment_details;
      END IF;
      RAISE;
  --
  END append_payment_details;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : FETCH_XML                                           --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns the next CLOB available in   --
  --                  global CLOB array                                   --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : N/A                                                 --
  --            OUT : p_clob                 CLOB                         --
  --------------------------------------------------------------------------
  --
  PROCEDURE fetch_xml (
                       p_clob    OUT NOCOPY CLOB
                      )
  IS
  --
    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
  --
  BEGIN
  --

   l_procedure := g_package||'fetch_xml';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);



	-- If Clobs exists return next clob else exit NULL
    IF (g_clob_cnt <> 0 ) AND (g_fetch_clob_cnt < g_clob_cnt) THEN
    --
      g_fetch_clob_cnt := g_fetch_clob_cnt + 1;
      p_clob := g_clob(g_fetch_clob_cnt);
    --
    ELSE
    --
      p_clob := null;
    --
    END IF;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  END fetch_xml;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : LOAD_XML                                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure makes a list of XMLs in a global     --
  --                  CLOB array                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id     NUMBER                      --
  --                  p_start_date            VARCHAR2                    --
  --                  p_end_date              VARCHAR2                    --
  --                  p_payroll_id            NUMBER                      --
  --                  p_consolidation_set_id  NUMBER                      --
  --                  p_assignment_set_id     NUMBER                      --
  --                  p_employee_number       NUMBER                      --
  --                  p_sort_order1           VARCHAR2                    --
  --                  p_sort_order2           VARCHAR2                    --
  --                  p_sort_order3           VARCHAR2                    --
  --                  p_sort_order4           VARCHAR2                    --
  --            OUT : p_clob_cnt              NUMBER                      --
  --------------------------------------------------------------------------
  --
  PROCEDURE load_xml (
                      p_business_group_id    IN NUMBER
                     ,p_start_date           IN VARCHAR2
                     ,p_end_date             IN VARCHAR2
                     ,p_payroll_id           IN NUMBER   DEFAULT NULL
                     ,p_consolidation_set_id IN NUMBER   DEFAULT NULL
                     ,p_assignment_set_id    IN NUMBER   DEFAULT NULL
                     ,p_employee_number      IN NUMBER   DEFAULT NULL
                     ,p_sort_order1          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order2          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order3          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order4          IN VARCHAR2 DEFAULT NULL
                     ,p_clob_cnt             OUT NOCOPY NUMBER
                     )
  IS
  --
    --
    l_open_tag          VARCHAR2(100);
    l_close_tag         VARCHAR2(100);
    l_emp_open_tag      VARCHAR2(100);
    l_emp_close_tag     VARCHAR2(100);
    l_emp_cnt           NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_stmt              VARCHAR2(5000);
    l_sort_by           VARCHAR2(100);
    l_action_context_id NUMBER;
    l_sql_csr           INTEGER;
    l_dummy             INTEGER;
    l_employee_number   VARCHAR2(240);
    l_assignment_number VARCHAR2(240);
    l_employer_name     VARCHAR2(240);
    l_dob               DATE;
    l_joining_date      DATE;
    l_ptn               VARCHAR2(240);
    l_pf_number         VARCHAR2(240);
    l_esi_number        VARCHAR2(240);
    l_emp_name          VARCHAR2(240);
    l_pay_month         VARCHAR2(240);
    l_er_location       VARCHAR2(240);
    l_email_addr        VARCHAR2(240);
    l_emp_addr          VARCHAR2(500);
    l_job               VARCHAR2(240);
    l_position          VARCHAR2(240);
    l_grade             VARCHAR2(240);
    l_pan               VARCHAR2(240);
    l_superannuation    VARCHAR2(240);
    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);

  --
  BEGIN
  --

   l_procedure := g_package ||'get_template';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_business_group_id    : ', p_business_group_id);
     pay_in_utils.trace('p_start_date           : ', p_start_date);
     pay_in_utils.trace('p_end_date             : ', p_end_date);
     pay_in_utils.trace('p_payroll_id           : ', p_payroll_id);
     pay_in_utils.trace('p_consolidation_set_id : ', p_consolidation_set_id);
     pay_in_utils.trace('p_assignment_set_id    : ', p_assignment_set_id);
     pay_in_utils.trace('p_employee_number      : ', p_employee_number);
     pay_in_utils.trace('p_sort_order1          : ', p_sort_order1);
     pay_in_utils.trace('p_sort_order2          : ', p_sort_order2);
     pay_in_utils.trace('p_sort_order3          : ', p_sort_order3);
     pay_in_utils.trace('p_sort_order4          : ', p_sort_order4);
     pay_in_utils.trace('**************************************************','********************');
   END IF;


    l_start_date := fnd_date.canonical_to_date(p_start_date);
    l_end_date := fnd_date.canonical_to_date(p_end_date);
    g_business_group_id := p_business_group_id;

	-- Construct SQL statement
	--
    l_stmt := ' SELECT piaav.assignment_action_id action_context_id
                      ,peaiv.action_information10 employee_number
                      ,peaiv.action_information14 assignment_number
                      ,peaiv.action_information18 gre_name
                      ,pay_us_employee_payslip_web.format_to_date(peaiv.action_information13) dob
                      ,pay_us_employee_payslip_web.format_to_date(peaiv.action_information11) joining_date
                      ,peaiv.action_information8 ptn
                      ,peaiv.action_information24 pf_number
                      ,peaiv.action_information6  esi_number
                      ,peaiv.action_information1  emp_name
      		      ,pay_in_soe.get_emp_email(peaiv.action_context_id) email_addr
       		      ,pay_in_soe.get_emp_address(paf.person_id,:end_date) emp_addr
                      ,peaiv.action_information23 pay_month
                      ,peaiv.action_information30 er_location
                      ,peaiv.action_information17 job
                      ,peaiv.action_information19 position
                      ,peaiv.action_information7  grade
                      ,peaiv.action_information25 pan
                      ,peaiv.action_information27 superannuation
		      ,peaiv.action_information1  full_name
		      ,peaiv.action_information30 location_name
		      ,peaiv.action_information15 organization_name
                FROM   pay_in_arch_actions_v piaav
                      ,pay_action_information peaiv
		      ,pay_assignment_actions paa
		      ,per_all_assignments_f paf
                WHERE  piaav.business_group_id = :bg_id
		AND    piaav.business_group_id = paf.business_group_id
                AND    piaav.effective_date BETWEEN :start_date
                                            AND     :end_date
                AND  ( :payroll_id = -1 OR :payroll_id =  piaav.payroll_id)
                AND  ( :cons_set_id = -1 OR :cons_set_id =
                       piaav.consolidation_set_id)
                AND  DECODE (:assg_set_id,-1,''Y'',
                     DECODE (hr_assignment_set.ASSIGNMENT_IN_SET(:assg_set_id,paf.assignment_id),''Y'',''Y'',''N'')) = ''Y''
		AND  ( :person_id = -1 OR paf.person_id = :person_id)
		AND  paf.assignment_id = paa.assignment_id
                AND  peaiv.action_context_id = piaav.assignment_action_id
                AND  peaiv.action_context_type = ''AAP''
                AND  peaiv.action_information_category = ''EMPLOYEE DETAILS''
		AND  paa.assignment_action_id = peaiv.action_context_id
	        AND    (TO_CHAR(paf.effective_start_date,''Month-YYYY'')=to_char(:end_date,''Month-YYYY'')
                       OR  TO_CHAR(paf.effective_end_date,''Month-YYYY'')=to_char(:end_date,''Month-YYYY'')
                       OR  :end_date between paf.effective_start_date and paf.effective_end_date)';


	-- Construct the sort order
	--
    l_sort_by := NULL;
    IF p_sort_order1 IS NOT NULL THEN
    --
      l_sort_by := 'ORDER BY '||p_sort_order1;

      IF p_sort_order2 IS NOT NULL THEN
      --
        l_sort_by := l_sort_by ||','||p_sort_order2;
        IF p_sort_order3 IS NOT NULL THEN
        --
          l_sort_by := l_sort_by ||','||p_sort_order3;
          IF p_sort_order4 IS NOT NULL THEN
          --
            l_sort_by := l_sort_by ||','||p_sort_order4;
          --
          END IF;
        --
        END IF;
      --
      END IF;
    --
    END IF;

    l_emp_cnt       := 0;
    l_open_tag      := '<?xml version="1.0" encoding="UTF-8"?>
                      <clob>';

	-- Append sort order to SQL statement
	--
    l_stmt := l_stmt || l_sort_by;

    pay_in_utils.trace('Before Open Cursor',20);
    l_sql_csr := dbms_sql.open_cursor;

    pay_in_utils.set_location(g_debug,'Before parse',30);
    dbms_sql.parse(l_sql_csr,l_stmt,dbms_sql.native);
    dbms_sql.define_column(l_sql_csr,1,l_action_context_id);
    dbms_sql.define_column(l_sql_csr,2,l_employee_number,240);
    dbms_sql.define_column(l_sql_csr,3,l_assignment_number,240);
    dbms_sql.define_column(l_sql_csr,4,l_employer_name,240);
    dbms_sql.define_column(l_sql_csr,5,l_dob);
    dbms_sql.define_column(l_sql_csr,6,l_joining_date);
    dbms_sql.define_column(l_sql_csr,7,l_ptn,240);
    dbms_sql.define_column(l_sql_csr,8,l_pf_number,240);
    dbms_sql.define_column(l_sql_csr,9,l_esi_number,240);
    dbms_sql.define_column(l_sql_csr,10,l_emp_name,240);
    dbms_sql.define_column(l_sql_csr,11,l_email_addr,240);
    dbms_sql.define_column(l_sql_csr,12,l_emp_addr,500);
    dbms_sql.define_column(l_sql_csr,13,l_pay_month,240);
    dbms_sql.define_column(l_sql_csr,14,l_er_location,240);
    dbms_sql.define_column(l_sql_csr,15,l_job,240);
    dbms_sql.define_column(l_sql_csr,16,l_position,240);
    dbms_sql.define_column(l_sql_csr,17,l_grade,240);
    dbms_sql.define_column(l_sql_csr,18,l_pan,240);
    dbms_sql.define_column(l_sql_csr,19,l_superannuation,240);

    pay_in_utils.set_location(g_debug,'Before Bind',40);
    dbms_sql.bind_variable(l_sql_csr,':bg_id',p_business_group_id);
    dbms_sql.bind_variable(l_sql_csr,':start_date',l_start_date);
    dbms_sql.bind_variable(l_sql_csr,':end_date',l_end_date);
    dbms_sql.bind_variable(l_sql_csr,':payroll_id',p_payroll_id);
    dbms_sql.bind_variable(l_sql_csr,':cons_set_id',p_consolidation_set_id);
    dbms_sql.bind_variable(l_sql_csr,':assg_set_id',p_assignment_set_id);
    dbms_sql.bind_variable(l_sql_csr,':person_id',p_employee_number);


    pay_in_utils.set_location(g_debug,'Before execute',50);
    l_dummy := dbms_sql.execute(l_sql_csr);

    LOOP
    --
	  -- Fetch next row
	  --
      IF (dbms_sql.fetch_rows(l_sql_csr) <= 0) THEN
      --
		-- No More rows exist, Exit.
        EXIT;
      --
      END IF;
      dbms_sql.column_value(l_sql_csr,1,l_action_context_id);
      dbms_sql.column_value(l_sql_csr,2,l_employee_number);
      dbms_sql.column_value(l_sql_csr,3,l_assignment_number);
      dbms_sql.column_value(l_sql_csr,4,l_employer_name);
      dbms_sql.column_value(l_sql_csr,5,l_dob);
      dbms_sql.column_value(l_sql_csr,6,l_joining_date);
      dbms_sql.column_value(l_sql_csr,7,l_ptn);
      dbms_sql.column_value(l_sql_csr,8,l_pf_number);
      dbms_sql.column_value(l_sql_csr,9,l_esi_number);
      dbms_sql.column_value(l_sql_csr,10,l_emp_name);
      dbms_sql.column_value(l_sql_csr,11,l_email_addr);
      dbms_sql.column_value(l_sql_csr,12,l_emp_addr);
      dbms_sql.column_value(l_sql_csr,13,l_pay_month);
      dbms_sql.column_value(l_sql_csr,14,l_er_location);
      dbms_sql.column_value(l_sql_csr,15,l_job);
      dbms_sql.column_value(l_sql_csr,16,l_position);
      dbms_sql.column_value(l_sql_csr,17,l_grade);
      dbms_sql.column_value(l_sql_csr,18,l_pan);
      dbms_sql.column_value(l_sql_csr,19,l_superannuation);

      pay_in_utils.trace('l_action_context_id : ', l_action_context_id);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('l_employee_number   : ', l_employee_number);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('l_assignment_number : ', l_assignment_number);
      pay_in_utils.set_location(g_debug,l_procedure,30);
      pay_in_utils.trace('l_dob               : ', l_dob);
      pay_in_utils.set_location(g_debug,l_procedure,40);
      pay_in_utils.trace('l_joining_date      : ', l_joining_date);
      pay_in_utils.set_location(g_debug,l_procedure,50);
      pay_in_utils.trace('l_ptn               : ', l_ptn);
      pay_in_utils.set_location(g_debug,l_procedure,60);
      pay_in_utils.trace('l_pf_number         : ', l_pf_number);
      pay_in_utils.set_location(g_debug,l_procedure,70);
      pay_in_utils.trace('l_esi_number        : ', l_esi_number);
      pay_in_utils.set_location(g_debug,l_procedure,80);
      pay_in_utils.trace('l_pay_month         : ', l_pay_month);
      pay_in_utils.set_location(g_debug,l_procedure,90);
      pay_in_utils.trace('l_job               : ', l_job);
      pay_in_utils.set_location(g_debug,l_procedure,100);
      pay_in_utils.trace('l_position          : ', l_position);
      pay_in_utils.set_location(g_debug,l_procedure,110);
      pay_in_utils.trace('l_grade             : ', l_grade);
      pay_in_utils.set_location(g_debug,l_procedure,120);
      pay_in_utils.trace('l_emp_cnt             : ', l_emp_cnt);
      pay_in_utils.set_location(g_debug,l_procedure,130);

      IF ( l_emp_cnt = 0) OR ( l_emp_cnt >=g_chunk_size ) THEN
      --
        pay_in_utils.set_location(g_debug,'Inside If emp_cnt = 0 or emp_cnt > chunk_size',70);

		-- If not the first employee close the previous clob
		-- Put the clob in the global CLOB array
		--
        IF ( l_emp_cnt <> 0) THEN
        --
          close_tag('clob');
          dbms_lob.close(g_tmp_clob);
          g_clob(g_clob_cnt):=g_tmp_clob;
          l_emp_cnt := 0;
        --
        END IF;

		-- Increment global clob count
		--
        g_clob_cnt := g_clob_cnt + 1;

      pay_in_utils.trace('g_clob_cnt             : ', g_clob_cnt);
      pay_in_utils.set_location(g_debug,l_procedure,140);

		-- Open a new CLOB
		--
        pay_in_utils.set_location(g_debug,'Before Create Temporary',150);
        dbms_lob.createtemporary(g_tmp_clob,FALSE,DBMS_LOB.CALL);

        pay_in_utils.set_location(g_debug,'Before Open',160);
        dbms_lob.open(g_tmp_clob,dbms_lob.lob_readwrite);

		-- Append Open tags to new CLOB
		--
        dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
      --
      END IF;

      pay_in_utils.set_location(g_debug,'Before employee tag',170);

	  -- Open Employee tag
	  -- Append Details
	  --
      open_tag('Employee');
      open_tag('PersonDetails');
        append_tag('EmpNumber',l_employee_number);
        append_tag('AssgNumber',l_assignment_number);
        append_tag('ERName',l_employer_name);
        append_tag('DOB',to_char(l_dob,'DD-MON-YYYY'));
        append_tag('JoiningDate',to_char(l_joining_date,'DD-MON-YYYY'));
        append_tag('PTN',l_ptn);
        append_tag('PFNumber',l_pf_number);
        append_tag('ESINumber',l_esi_number);
        append_tag('EmpName',l_emp_name);
        append_tag('EmailAddr',l_email_addr);
        append_tag('EmpAddr',l_emp_addr);
        append_tag('PayMonth',l_pay_month);
        append_tag('ERLocation',l_er_location);
        append_tag('Job',l_job);
        append_tag('Position',l_position);
        append_tag('GRADE',l_grade); /* Bug 4218967 Changed the tag Grade to GRADE */
        append_tag('PAN',l_pan);
        append_tag('SuperAnnuation',l_superannuation);
      close_tag('PersonDetails');

      append_elements(l_action_context_id,'Earnings');
      append_elements(l_action_context_id,'Deductions');
      append_elements(l_action_context_id,'Fringe Benefits');
      append_elements(l_action_context_id,'Advances');
      append_net_pay(l_action_context_id);
      append_elements(l_action_context_id,'Perquisites');
      append_elements(l_action_context_id,'Employer Charges');
      append_balances(l_action_context_id);
      append_payment_details(l_action_context_id);
      append_other_elements(l_action_context_id);
      append_other_balances(l_action_context_id);
      append_accruals(l_action_context_id);
      append_absences(l_action_context_id);
      append_messages(l_action_context_id);


	  -- Close employee tag
	  --
      close_tag('Employee');
      l_emp_cnt := l_emp_cnt + 1;
      pay_in_utils.set_location(g_debug,'After employee tag',180);
    --
    END LOOP;

    pay_in_utils.set_location(g_debug,'Close cursor',190);
    dbms_sql.close_cursor(l_sql_csr);

	-- Last CLOB is not yet closed
	-- So close it.
    IF ( g_clob_cnt <> 0) THEN
    --
      pay_in_utils.set_location(g_debug,'Closing last clob',200);
      close_tag('clob');
      dbms_lob.close(g_tmp_clob);
      g_clob(g_clob_cnt):=g_tmp_clob;
    --

    END IF;
    p_clob_cnt := g_clob_cnt;

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_clob_cnt    : ',p_clob_cnt);
     pay_in_utils.trace('**************************************************','********************');
   END IF;


    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,220);

    EXCEPTION
      WHEN others THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,230);
        pay_in_utils.trace(l_message,l_procedure);

     IF dbms_sql.is_open(l_sql_csr) THEN
        dbms_sql.close_cursor(l_sql_csr);
     END IF;
     RAISE;
  --
  END load_xml;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : LOAD_XML_BURST                                            --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure makes a list of XMLs in a global     --
  --                  CLOB for xml burst                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id     NUMBER                      --
  --                  p_start_date            VARCHAR2                    --
  --                  p_end_date              VARCHAR2                    --
  --                  p_payroll_id            NUMBER                      --
  --                  p_consolidation_set_id  NUMBER                      --
  --                  p_assignment_set_id     NUMBER                      --
  --                  p_employee_number       NUMBER                      --
  --                  p_sort_order1           VARCHAR2                    --
  --                  p_sort_order2           VARCHAR2                    --
  --                  p_sort_order3           VARCHAR2                    --
  --                  p_sort_order4           VARCHAR2                    --
  --            OUT : p_xml                   CLOB                        --
  --------------------------------------------------------------------------

PROCEDURE load_xml_burst (
                      p_business_group_id    IN NUMBER
                     ,p_start_date           IN VARCHAR2
                     ,p_end_date             IN VARCHAR2
                     ,p_payroll_id           IN NUMBER   DEFAULT NULL
                     ,p_consolidation_set_id IN NUMBER   DEFAULT NULL
                     ,p_assignment_set_id    IN NUMBER   DEFAULT NULL
                     ,p_employee_number      IN NUMBER   DEFAULT NULL
                     ,p_sort_order1          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order2          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order3          IN VARCHAR2 DEFAULT NULL
                     ,p_sort_order4          IN VARCHAR2 DEFAULT NULL
                     ,p_xml                  OUT NOCOPY CLOB
                     )
  IS
  --
    --
    l_open_tag          VARCHAR2(100);
    l_close_tag         VARCHAR2(100);
    l_emp_open_tag      VARCHAR2(100);
    l_emp_close_tag     VARCHAR2(100);
    l_emp_cnt           NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_stmt              VARCHAR2(5000);
    l_sort_by           VARCHAR2(100);
    l_action_context_id NUMBER;
    l_sql_csr           INTEGER;
    l_dummy             INTEGER;
    l_employee_number   VARCHAR2(240);
    l_assignment_number VARCHAR2(240);
    l_employer_name     VARCHAR2(240);
    l_dob               DATE;
    l_joining_date      DATE;
    l_ptn               VARCHAR2(240);
    l_pf_number         VARCHAR2(240);
    l_esi_number        VARCHAR2(240);
    l_emp_name          VARCHAR2(240);
    l_email_addr        VARCHAR2(240);
    l_emp_addr          VARCHAR2(500);
    l_pay_month         VARCHAR2(240);
    l_er_location       VARCHAR2(240);
    l_job               VARCHAR2(240);
    l_position          VARCHAR2(240);
    l_grade             VARCHAR2(240);
    l_pan               VARCHAR2(240);
    l_superannuation    VARCHAR2(240);
    l_procedure         VARCHAR2(100);
    l_message           VARCHAR2(250);
  --
  BEGIN
  --

   l_procedure := g_package ||'load_xml_burst';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_business_group_id    : ', p_business_group_id);
     pay_in_utils.trace('p_start_date           : ', p_start_date);
     pay_in_utils.trace('p_end_date             : ', p_end_date);
     pay_in_utils.trace('p_payroll_id           : ', p_payroll_id);
     pay_in_utils.trace('p_consolidation_set_id : ', p_consolidation_set_id);
     pay_in_utils.trace('p_assignment_set_id    : ', p_assignment_set_id);
     pay_in_utils.trace('p_employee_number      : ', p_employee_number);
     pay_in_utils.trace('p_sort_order1          : ', p_sort_order1);
     pay_in_utils.trace('p_sort_order2          : ', p_sort_order2);
     pay_in_utils.trace('p_sort_order3          : ', p_sort_order3);
     pay_in_utils.trace('p_sort_order4          : ', p_sort_order4);
     pay_in_utils.trace('**************************************************','********************');
   END IF;


    l_start_date := fnd_date.canonical_to_date(p_start_date);
    l_end_date := fnd_date.canonical_to_date(p_end_date);
    g_business_group_id := p_business_group_id;

	-- Construct SQL statement
	--
    l_stmt := ' SELECT piaav.assignment_action_id action_context_id
                      ,peaiv.action_information10 employee_number
                      ,peaiv.action_information14 assignment_number
                      ,peaiv.action_information18 gre_name
                      ,pay_us_employee_payslip_web.format_to_date(peaiv.action_information13) dob
                      ,pay_us_employee_payslip_web.format_to_date(peaiv.action_information11) joining_date
                      ,peaiv.action_information8 ptn
                      ,peaiv.action_information24 pf_number
                      ,peaiv.action_information6  esi_number
                      ,peaiv.action_information1  emp_name
                      ,pay_in_soe.get_emp_email(peaiv.action_context_id) email_addr
		      ,pay_in_soe.get_emp_address(paf.person_id,:end_date) emp_addr
                      ,peaiv.action_information23 pay_month
                      ,peaiv.action_information30 er_location
                      ,peaiv.action_information17 job
                      ,peaiv.action_information19 position
                      ,peaiv.action_information7  grade
                      ,peaiv.action_information25 pan
                      ,peaiv.action_information27 superannuation
		      ,peaiv.action_information1  full_name
		      ,peaiv.action_information30 location_name
		      ,peaiv.action_information15 organization_name
                FROM   pay_in_arch_actions_v piaav
                      ,pay_action_information peaiv
		      ,pay_assignment_actions paa
		      ,per_all_assignments_f paf
                WHERE  piaav.business_group_id = :bg_id
		AND    piaav.business_group_id = paf.business_group_id
                AND    piaav.effective_date BETWEEN :start_date
                                            AND     :end_date
                AND  ( :payroll_id = -1 OR :payroll_id =  piaav.payroll_id)
                AND  ( :cons_set_id = -1 OR :cons_set_id =
                       piaav.consolidation_set_id)
                AND  DECODE (:assg_set_id,-1,''Y'',
                     DECODE (hr_assignment_set.ASSIGNMENT_IN_SET(:assg_set_id,paf.assignment_id),''Y'',''Y'',''N'')) = ''Y''
		AND  ( :person_id = -1 OR paf.person_id = :person_id)
		AND  paf.assignment_id = paa.assignment_id
                AND  peaiv.action_context_id = piaav.assignment_action_id
		AND EXISTS (SELECT 1
                              FROM  pay_action_information pai
                             WHERE pai.action_information_category = ''IN_EMPLOYEE_DETAILS''
                               AND pai.action_context_id = peaiv.action_context_id
                               AND pai.action_information1 IS NOT NULL)
                AND  peaiv.action_context_type = ''AAP''
                AND  peaiv.action_information_category = ''EMPLOYEE DETAILS''
		AND  paa.assignment_action_id = peaiv.action_context_id
	        AND    (TO_CHAR(paf.effective_start_date,''Month-YYYY'')=to_char(:end_date,''Month-YYYY'')
                       OR  TO_CHAR(paf.effective_end_date,''Month-YYYY'')=to_char(:end_date,''Month-YYYY'')
                       OR  :end_date between paf.effective_start_date and paf.effective_end_date)';


	-- Construct the sort order
	--
    l_sort_by := NULL;
    IF p_sort_order1 IS NOT NULL THEN
    --
      l_sort_by := 'ORDER BY '||p_sort_order1;

      IF p_sort_order2 IS NOT NULL THEN
      --
        l_sort_by := l_sort_by ||','||p_sort_order2;
        IF p_sort_order3 IS NOT NULL THEN
        --
          l_sort_by := l_sort_by ||','||p_sort_order3;
          IF p_sort_order4 IS NOT NULL THEN
          --
            l_sort_by := l_sort_by ||','||p_sort_order4;
          --
          END IF;
        --
        END IF;
      --
      END IF;
    --
    END IF;

    l_emp_cnt       := 0;
    l_open_tag      := '<?xml version="1.0" encoding="UTF-8"?>';
	-- Append sort order to SQL statement
	--
    l_stmt := l_stmt || l_sort_by;

    pay_in_utils.trace('Before Open Cursor',20);
    l_sql_csr := dbms_sql.open_cursor;

    pay_in_utils.set_location(g_debug,'Before parse',30);
    dbms_sql.parse(l_sql_csr,l_stmt,dbms_sql.native);
    dbms_sql.define_column(l_sql_csr,1,l_action_context_id);
    dbms_sql.define_column(l_sql_csr,2,l_employee_number,240);
    dbms_sql.define_column(l_sql_csr,3,l_assignment_number,240);
    dbms_sql.define_column(l_sql_csr,4,l_employer_name,240);
    dbms_sql.define_column(l_sql_csr,5,l_dob);
    dbms_sql.define_column(l_sql_csr,6,l_joining_date);
    dbms_sql.define_column(l_sql_csr,7,l_ptn,240);
    dbms_sql.define_column(l_sql_csr,8,l_pf_number,240);
    dbms_sql.define_column(l_sql_csr,9,l_esi_number,240);
    dbms_sql.define_column(l_sql_csr,10,l_emp_name,240);
    dbms_sql.define_column(l_sql_csr,11,l_email_addr,240);
    dbms_sql.define_column(l_sql_csr,12,l_emp_addr,500);
    dbms_sql.define_column(l_sql_csr,13,l_pay_month,240);
    dbms_sql.define_column(l_sql_csr,14,l_er_location,240);
    dbms_sql.define_column(l_sql_csr,15,l_job,240);
    dbms_sql.define_column(l_sql_csr,16,l_position,240);
    dbms_sql.define_column(l_sql_csr,17,l_grade,240);
    dbms_sql.define_column(l_sql_csr,18,l_pan,240);
    dbms_sql.define_column(l_sql_csr,19,l_superannuation,240);

    pay_in_utils.set_location(g_debug,'Before Bind',40);
    dbms_sql.bind_variable(l_sql_csr,':bg_id',p_business_group_id);
    dbms_sql.bind_variable(l_sql_csr,':start_date',l_start_date);
    dbms_sql.bind_variable(l_sql_csr,':end_date',l_end_date);
    dbms_sql.bind_variable(l_sql_csr,':payroll_id',p_payroll_id);
    dbms_sql.bind_variable(l_sql_csr,':cons_set_id',p_consolidation_set_id);
    dbms_sql.bind_variable(l_sql_csr,':assg_set_id',p_assignment_set_id);
    dbms_sql.bind_variable(l_sql_csr,':person_id',p_employee_number);


    pay_in_utils.set_location(g_debug,'Before execute',50);
    l_dummy := dbms_sql.execute(l_sql_csr);

      dbms_lob.createtemporary(g_tmp_clob,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(g_tmp_clob,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
      open_tag('IN_SOE');

    LOOP
    --
	  -- Fetch next row
	  --
      IF (dbms_sql.fetch_rows(l_sql_csr) <= 0) THEN
      --
		-- No More rows exist, Exit.
        EXIT;
      --
      END IF;
      dbms_sql.column_value(l_sql_csr,1,l_action_context_id);
      dbms_sql.column_value(l_sql_csr,2,l_employee_number);
      dbms_sql.column_value(l_sql_csr,3,l_assignment_number);
      dbms_sql.column_value(l_sql_csr,4,l_employer_name);
      dbms_sql.column_value(l_sql_csr,5,l_dob);
      dbms_sql.column_value(l_sql_csr,6,l_joining_date);
      dbms_sql.column_value(l_sql_csr,7,l_ptn);
      dbms_sql.column_value(l_sql_csr,8,l_pf_number);
      dbms_sql.column_value(l_sql_csr,9,l_esi_number);
      dbms_sql.column_value(l_sql_csr,10,l_emp_name);
      dbms_sql.column_value(l_sql_csr,11,l_email_addr);
      dbms_sql.column_value(l_sql_csr,12,l_emp_addr);
      dbms_sql.column_value(l_sql_csr,13,l_pay_month);
      dbms_sql.column_value(l_sql_csr,14,l_er_location);
      dbms_sql.column_value(l_sql_csr,15,l_job);
      dbms_sql.column_value(l_sql_csr,16,l_position);
      dbms_sql.column_value(l_sql_csr,17,l_grade);
      dbms_sql.column_value(l_sql_csr,18,l_pan);
      dbms_sql.column_value(l_sql_csr,19,l_superannuation);

      pay_in_utils.trace('l_action_context_id : ', l_action_context_id);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('l_employee_number   : ', l_employee_number);
      pay_in_utils.set_location(g_debug,l_procedure,20);
      pay_in_utils.trace('l_assignment_number : ', l_assignment_number);
      pay_in_utils.set_location(g_debug,l_procedure,30);
      pay_in_utils.trace('l_dob               : ', l_dob);
      pay_in_utils.set_location(g_debug,l_procedure,40);
      pay_in_utils.trace('l_joining_date      : ', l_joining_date);
      pay_in_utils.set_location(g_debug,l_procedure,50);
      pay_in_utils.trace('l_ptn               : ', l_ptn);
      pay_in_utils.set_location(g_debug,l_procedure,60);
      pay_in_utils.trace('l_pf_number         : ', l_pf_number);
      pay_in_utils.set_location(g_debug,l_procedure,70);
      pay_in_utils.trace('l_esi_number        : ', l_esi_number);
      pay_in_utils.set_location(g_debug,l_procedure,80);
      pay_in_utils.trace('l_pay_month         : ', l_pay_month);
      pay_in_utils.set_location(g_debug,l_procedure,90);
      pay_in_utils.trace('l_job               : ', l_job);
      pay_in_utils.set_location(g_debug,l_procedure,100);
      pay_in_utils.trace('l_position          : ', l_position);
      pay_in_utils.set_location(g_debug,l_procedure,110);
      pay_in_utils.trace('l_grade             : ', l_grade);
      pay_in_utils.set_location(g_debug,l_procedure,120);
      pay_in_utils.trace('l_emp_cnt             : ', l_emp_cnt);
      pay_in_utils.set_location(g_debug,l_procedure,130);

      pay_in_utils.set_location(g_debug,'Before employee tag',170);


	  -- Open Employee tag
	  -- Append Details
	  --

      open_tag('Employee');
      open_tag('PersonDetails');
        append_tag('EmpNumber',l_employee_number);
        append_tag('AssgNumber',l_assignment_number);
        append_tag('ERName',l_employer_name);
        append_tag('DOB',to_char(l_dob,'DD-MON-YYYY'));
        append_tag('JoiningDate',to_char(l_joining_date,'DD-MON-YYYY'));
        append_tag('PTN',l_ptn);
        append_tag('PFNumber',l_pf_number);
        append_tag('ESINumber',l_esi_number);
        append_tag('EmpName',l_emp_name);
        append_tag('EmailAddr',l_email_addr);
        append_tag('EmpAddr',l_emp_addr);
        append_tag('PayMonth',l_pay_month);
        append_tag('ERLocation',l_er_location);
        append_tag('Job',l_job);
        append_tag('Position',l_position);
        append_tag('GRADE',l_grade); /* Bug 4218967 Changed the tag Grade to GRADE */
        append_tag('PAN',l_pan);
        append_tag('SuperAnnuation',l_superannuation);
      close_tag('PersonDetails');

      append_elements(l_action_context_id,'Earnings');
      append_elements(l_action_context_id,'Deductions');
      append_elements(l_action_context_id,'Fringe Benefits');
      append_elements(l_action_context_id,'Advances');
      append_net_pay(l_action_context_id);
      append_elements(l_action_context_id,'Perquisites');
      append_elements(l_action_context_id,'Employer Charges');
      append_balances(l_action_context_id);
      append_payment_details(l_action_context_id);
      append_other_elements(l_action_context_id);
      append_other_balances(l_action_context_id);
      append_accruals(l_action_context_id);
      append_absences(l_action_context_id);
      append_messages(l_action_context_id);


	  -- Close employee tag
	  --
      close_tag('Employee');

  /*    l_emp_cnt := l_emp_cnt + 1;*/
      pay_in_utils.set_location(g_debug,'After employee tag',180);
    --
    END LOOP;
    close_tag('IN_SOE');
    pay_in_utils.set_location(g_debug,'Close cursor',190);
    dbms_sql.close_cursor(l_sql_csr);



     dbms_lob.close(g_tmp_clob);
     p_xml := g_tmp_clob;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,220);

    EXCEPTION
      WHEN others THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,230);
        pay_in_utils.trace(l_message,l_procedure);

     IF dbms_sql.is_open(l_sql_csr) THEN
        dbms_sql.close_cursor(l_sql_csr);
     END IF;
     RAISE;
  --
  END load_xml_burst;



--
BEGIN
--
  -- Initialize Globals
  --
  g_clob_cnt       := 0;
  g_fetch_clob_cnt := 0;
  g_chunk_size     := 500;
--
END pay_in_soe;

/
