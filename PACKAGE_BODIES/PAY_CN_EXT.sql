--------------------------------------------------------
--  DDL for Package Body PAY_CN_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_EXT" AS
/* $Header: pycnext.pkb 120.0.12010000.2 2008/08/06 07:02:52 ubhat ship $ */

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : INITIALIZE_GLOBALS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Private                                               --
  -- Description    : Function to set global variables so that they are     --
  --                  accessible to all threads                             --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_phf_si_type          VARCHAR2                       --
  --                  p_start_date           DATE                           --
  --                  p_end_date             DATE                           --
  --                  p_legal_employer_id    NUMBER                         --
  --                  p_business_group_id    NUMBER                         --
  --                  p_contribution_area    VARCHAR2                       --
  --                  p_contribution_year    VARCHAR2                       --
  --                  p_filling_date         DATE                           --
  --                  p_report_type          VARCHAR2                       --
  --            OUT :                                                       --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  PROCEDURE initialize_globals ( p_phf_si_type          IN VARCHAR2
                               , p_start_date           IN DATE
                               , p_end_date             IN DATE
                               , p_legal_employer_id    IN NUMBER
                               , p_business_group_id    IN NUMBER
                               , p_contribution_area    IN VARCHAR2
                               , p_contribution_year    IN VARCHAR2
                               , p_filling_date         IN DATE
                               , p_report_type          IN VARCHAR2
                               )
  IS
  --
    l_proc_name   VARCHAR2(150);
    l_request_id  NUMBER ;
  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.initialize_globals';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    l_request_id := fnd_global.conc_request_id;

    hr_utility.set_location('China : Request ID -> '||l_request_id, 20);

    hr_utility.set_location('China : Inserting into pay_action_information ', 30);

    -- Insert the parameters into pay_action_information table so that
    -- the parameters are available to other threads based on the request ID
    --
    INSERT INTO pay_action_information
      ( action_information_id
      , action_context_id            -- Request Id
      , action_context_type          -- EXT
      , action_information_category  -- EXT_INFO
      , action_information1          -- PHF / SI Type
      , action_information2          -- Start Date
      , action_information3          -- End Date
      , action_information4          -- Legal Employer Id
      , action_information5          -- Business Group Id
      , action_information6          -- Contribution Area
      , action_information7          -- Contribution Year
      , action_information8          -- Filling Date
      , action_information9          -- Report Type
      )
    VALUES
      ( pay_action_information_s.nextval
      , l_request_id
      , 'EXT'
      , 'EXT_INFO'
      , p_phf_si_type
      , p_start_date
      , p_end_date
      , p_legal_employer_id
      , p_business_group_id
      , p_contribution_area
      , p_contribution_year
      , p_filling_date
      , p_report_type
      );


    COMMIT;

    hr_utility.set_location('China : Inserted into pay_action_information ', 40);

    hr_utility.set_location('China : Leaving -> '||l_proc_name, 10);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 50);
      RAISE;

  END initialize_globals;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : DELETE_GLOBALS                                        --
  -- Type           : PROCEDURE                                             --
  -- Access         : Private                                               --
  -- Description    : Function to delete global variables stored in table   --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :                                                       --
  --            OUT :                                                       --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  PROCEDURE delete_globals
  IS
  --
    l_proc_name   VARCHAR2(150);
    l_request_id  NUMBER ;
  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.delete_globals';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    l_request_id := fnd_global.conc_request_id;

    hr_utility.set_location('China : Request ID -> '||l_request_id, 20);

    hr_utility.set_location('China : Deleting row pay_action_information ', 30);

    -- Delete from Pay_action_information
    --
    DELETE FROM pay_action_information
    WHERE  action_context_id            = l_request_id
    AND    action_context_type          = 'EXT'
    AND    action_information_category  = 'EXT_INFO';

    COMMIT;

    hr_utility.set_location('China : Deleted from pay_action_information ', 40);

    hr_utility.set_location('China : Leaving -> '||l_proc_name, 10);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 50);
      RAISE;

  END delete_globals;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_GLOBALS                                           --
  -- Type           : PROCEDURE                                             --
  -- Access         : Private                                               --
  -- Description    : Function to get global variables                      --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :                                                       --
  --            OUT : p_phf_si_type           VARCHAR2                      --
  --                  p_start_date            DATE                          --
  --                  p_end_date              DATE                          --
  --                  p_legal_employer_id     NUMBER                        --
  --                  p_business_group_id     NUMBER                        --
  --                  p_contribution_area     VARCHAR2                      --
  --                  p_contribution_year     VARCHAR2                      --
  --                  p_filling_date          DATE                          --
  --                  p_report_type           VARCHAR2                      --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  ----------------------------------------------------------------------------
  PROCEDURE get_globals ( p_phf_si_type          OUT NOCOPY VARCHAR2
                        , p_start_date           OUT NOCOPY DATE
                        , p_end_date             OUT NOCOPY DATE
                        , p_legal_employer_id    OUT NOCOPY NUMBER
                        , p_business_group_id    OUT NOCOPY NUMBER
                        , p_contribution_area    OUT NOCOPY VARCHAR2
                        , p_contribution_year    OUT NOCOPY VARCHAR2
                        , p_filling_date         OUT NOCOPY DATE
                        , p_report_type          OUT NOCOPY VARCHAR2
                        )
  IS
  --

    -- Declare local Variables
    --
    l_proc_name   VARCHAR2(50);
    l_request_id  NUMBER;
    l_parent_id   NUMBER;

    l_phf_si_type        VARCHAR2(50);
    l_start_date         DATE;
    l_end_date           DATE;
    l_legal_employer_id  NUMBER;
    l_business_group_id  NUMBER;
    l_contribution_area  VARCHAR2(30);
    l_contribution_year  VARCHAR2(30);
    l_filling_date       DATE;
    l_report_type        VARCHAR2(3);

    -- Cursor to fetch the Parent request id
    -- If the parent reuest id is -1 (meaning it does not have a parent request)
    -- then parent request id should be taken as NULL
    --
    CURSOR  csr_parent_req_id (p_request_id NUMBER)
    IS
    --
      SELECT decode(parent_request_id,-1,null,parent_request_id)
      FROM   fnd_concurrent_requests
      WHERE  request_id = p_request_id;
    --


    -- Cursor to fetch the data from pay_action_information based on
    -- request IDs
    --
    CURSOR  csr_ext_info( p_request_id NUMBER
                        , p_parent_id  NUMBER)
    IS
    --
      SELECT action_information1          -- PHF / SI Type
           , action_information2          -- Start Date
           , action_information3          -- End Date
           , action_information4          -- Legal Employer Id
           , action_information5          -- Business Group Id
           , action_information6          -- Contribution Area
           , action_information7          -- Contribution Year
           , action_information8          -- Filling Date
           , action_information9          -- Report Type
      FROM   pay_action_information
      WHERE  action_context_id IN ( p_request_id, p_parent_id)
      AND    action_context_type          = 'EXT'
      AND    action_information_category  = 'EXT_INFO';
    --

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.get_globals';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    l_request_id := fnd_global.conc_request_id;

    hr_utility.set_location('China : Process Request ID -> '||l_request_id, 20);

    -- Get parent request id
    --
    OPEN csr_parent_req_id (l_request_id);
    FETCH csr_parent_req_id
      INTO l_parent_id;
    CLOSE csr_parent_req_id;

    hr_utility.set_location('China : Parent Request ID -> '||l_parent_id, 30);

    hr_utility.set_location('China : Before csr_ext_info ', 40);

    -- Get Parameter Values
    --
    OPEN csr_ext_info (l_request_id
                      ,l_parent_id);
    FETCH csr_ext_info
      INTO l_phf_si_type
          ,l_start_date
          ,l_end_date
          ,l_legal_employer_id
          ,l_business_group_id
          ,l_contribution_area
          ,l_contribution_year
          ,l_filling_date
          ,l_report_type;

    CLOSE csr_ext_info;

    hr_utility.set_location('China : After csr_ext_info ', 50);

    -- Copy the local variables into OUT parameters
    --
    p_phf_si_type        := l_phf_si_type;
    p_start_date         := l_start_date;
    p_end_date           := l_end_date;
    p_legal_employer_id  := l_legal_employer_id;
    p_business_group_id  := l_business_group_id;
    p_contribution_area  := l_contribution_area;
    p_contribution_year  := l_contribution_year;
    p_filling_date       := l_filling_date;
    p_report_type        := l_report_type;

    hr_utility.set_location('China : Leaving -> '||l_proc_name, 60);

  EXCEPTION
    WHEN OTHERS THEN
      IF csr_ext_info%ISOPEN THEN
        CLOSE csr_ext_info;
      END IF;
      RAISE;

  END get_globals;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_ELEMENT_NAME                                      --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to get the element name of the  PHF/SI type  --
  --                  given in concurrent request                           --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :                                                       --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   30-Aug-2004   sshankar  Added code for Enterprise Annuity        --
  --                               (Bug 3860274)                            --
  ----------------------------------------------------------------------------
  FUNCTION get_element_name(p_phf_si_type   IN VARCHAR2)
  RETURN VARCHAR2
  IS
  --
    l_element_name       pay_element_types_f.element_name%TYPE;
    l_proc_name          VARCHAR2(150);

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.get_element_name';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    -- Set l_element_name depending on the value of l_phf_si_type
    --
    IF p_phf_si_type = 'INJURY' THEN
    --
      l_element_name := 'Injury Insurance Information';

    ELSIF p_phf_si_type = 'MATERNITY' THEN
    --
      l_element_name  :=  'Maternity Insurance Information';

    ELSIF p_phf_si_type = 'MEDICAL' THEN
    --
      l_element_name :=  'Medical Information';

    ELSIF p_phf_si_type = 'PENSION' THEN
    --
      l_element_name :=  'Pension Information';

    ELSIF p_phf_si_type = 'PHF' THEN
    --
      l_element_name :=  'PHF Information';

    ELSIF p_phf_si_type = 'SUPPMED' THEN
    --
      l_element_name :=  'Supplementary Medical Information';

    ELSIF p_phf_si_type = 'UNEMPLOYMENT' THEN
    --
      l_element_name :=  'Unemployment Insurance Information';

    --
    -- Bug 3860275
    -- Enterprise Annuity to be included in this list of element names.
    --
    ELSIF p_phf_si_type = 'ENTANN' THEN
    --
      l_element_name :=  'Enterprise Annuity Information';

    --
    END IF;

    hr_utility.set_location('China : l_phf_si_type   -> '    || p_phf_si_type , 20);
    hr_utility.set_location('China : l_element_name   -> '    || l_element_name , 30);
    hr_utility.set_location('China :  Leaving -> '|| l_proc_name , 40);

    RETURN l_element_name;
  --
  END get_element_name;



  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CB_EXTRACT_PROCESS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Public                                                --
  -- Description    : Procedure for CB Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :  p_phf_si_type         VARCHAR2                       --
  --                   p_legal_employer_id   NUMBER DEFAULT NULL            --
  --                   p_contribution_area   VARCHAR2                       --
  --                   p_contribution_year   VARCHAR2                       --
  --                   p_business_group_id   NUMBER                         --
  --           OUT  :  errbuf               VARCHAR2                        --
  --                   retcode              VARCHAR2                        --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  -- 1.1   06-Jul-2004   sshankar  Added new parameter p_assignment_id in   --
  --                               call to get_phf_si_rates, to support     --
  --                               Enterprise Annuity (Bug 3593118)         --
  -- 1.2   14-Mar-2008   dduvvuri  Modified the call to get_phf_si_rates(bug 6828199)
  ----------------------------------------------------------------------------
  PROCEDURE cb_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                              , retcode              OUT  NOCOPY VARCHAR2
                              , p_phf_si_type        IN   VARCHAR2
                              , p_legal_employer_id  IN   NUMBER
                              , p_contribution_area  IN   VARCHAR2
                              , p_contribution_year  IN   VARCHAR2
                              , p_business_group_id  IN   NUMBER
                              )
  IS
  --

    -- Declare local Variables
    --
    l_errbuf               VARCHAR2(3000);
    l_retcode              VARCHAR2(2000);
    l_proc_name            VARCHAR2(150);
    l_extract_def_id       ben_ext_dfn.ext_dfn_id%TYPE;
    l_start_month          NUMBER;
    l_message              VARCHAR2(3000);
    l_ee_rate_type         VARCHAR2(30);
    l_er_rate_type         VARCHAR2(30);
    l_ee_rate              VARCHAR2(30);
    l_er_rate              VARCHAR2(30);
    l_ee_rounding_method   VARCHAR2(30);
    l_er_rounding_method   VARCHAR2(30);
    /* Changes for bug 6828199 start */
    l_ee_thrhld_rate       VARCHAR2(30);
    l_er_thrhld_rate       VARCHAR2(30);
    /* Changes for bug 6828199 end */
    l_start_date           DATE;
    l_end_date             DATE;

    --

    -- Cursor to fetch extract definition id of 'CB Extract'
    --
    CURSOR csr_extract_def_id
    IS
    --
      SELECT ed.ext_dfn_id
      FROM   ben_ext_dfn ed, hr_lookups hrl, per_business_groups bg
      WHERE  ((bg.business_group_id  = ed.business_group_id)
      OR      (bg.legislation_code   = ed.legislation_code)
      OR      (ed.business_group_id  IS NULL AND ed.legislation_code IS NULL))
      AND    bg.business_group_id    = p_business_group_id
      AND    ed.data_typ_cd          = hrl.lookup_code
      AND    hrl.lookup_type         = 'BEN_EXT_DATA_TYP'
      AND    SUBSTR(ed.NAME,1,240)   = 'CB Extract';
    --

    -- Cursor to fetch Switch Period month
    --
    -- Bug 3415164
    -- Added additional condition to check whether org_information3 is null
    -- and effective_date check
    -- SYSDATE is used because we assume that CB Report is run on the switch period month and
    -- Value for 'Switch Period Month' on SYSDATE should be used.
    --
    CURSOR csr_start_month
    IS
    --
      SELECT org_information11  -- Switch Period Month
      FROM   hr_organization_information
      WHERE  organization_id         = p_business_group_id
      AND    org_information_context = 'PER_CONT_AREA_CONT_BASE_CN'
      AND    org_information1        = p_contribution_area
      AND    org_information2        = p_phf_si_type
      AND    org_information10       = 'YEARLY'  -- Switch Period Periodicity is hardcoded.
      AND    org_information3        IS NULL
      AND    SYSDATE                 BETWEEN TO_DATE(org_information15,'YYYY/MM/DD HH24:MI:SS')
                                     AND     TO_DATE(NVL(org_information16,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS');
    --
  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.cb_extract_process';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    hr_utility.set_location('China : Before csr_extract_def_id ', 20);

    -- Fetch Extract Definition Id
    --
    OPEN csr_extract_def_id;
    FETCH csr_extract_def_id
      INTO l_extract_def_id;

    -- If Extract Definition does not exist return
    IF csr_extract_def_id%NOTFOUND THEN
    --
      hr_utility.set_location('China : Extract Definition not Found ' , 30);
      CLOSE csr_extract_def_id;
      RETURN;
    --
    END IF;
    --

    CLOSE csr_extract_def_id;

    hr_utility.set_location('China : After csr_extract_def_id ', 40);

    hr_utility.set_location('China : l_extract_def_id      -> '    || l_extract_def_id    , 45);
    hr_utility.set_location('China : p_phf_si_type         -> '    || p_phf_si_type       , 45);
    hr_utility.set_location('China : p_start_date          -> '    || l_start_date        , 45);
    hr_utility.set_location('China : p_end_date            -> '    || l_end_date          , 45);
    hr_utility.set_location('China : p_legal_employer_id   -> '    || p_legal_employer_id , 45);
    hr_utility.set_location('China : p_business_group_id   -> '    || p_business_group_id , 45);
    hr_utility.set_location('China : p_contribution_area   -> '    || p_contribution_area , 45);
    hr_utility.set_location('China : p_contribution_year   -> '    || p_contribution_year , 45);

    hr_utility.set_location('China : Before csr_start_month ', 50);

    -- Calculation of the start_date
    --
    OPEN csr_start_month;
    FETCH csr_start_month
      INTO l_start_month;

    -- If Switch month is not found
    --
    IF csr_start_month%NOTFOUND THEN
    --
      hr_utility.set_location('China : Switch Period Month not found ' , 55);
      CLOSE csr_start_month;
      RETURN;
    --
    END IF;
    --

    CLOSE csr_start_month;

    hr_utility.set_location('China : After csr_start_month ', 60);

    -- Set the first Day of the Switch Month as the Start Date for the report
    l_start_date := TO_DATE( '01-'||l_start_month||'-'||p_contribution_year , 'DD-MM-YYYY');

    hr_utility.set_location('China : l_start_date -> '|| l_start_date , 70);

    -- Add 11 months to the start date to get the end date
    l_end_date   := LAST_DAY(ADD_MONTHS(l_start_date,11));

    hr_utility.set_location('China : l_end_date -> '|| l_end_date , 80);

    -- Set Global Variables
    --

    initialize_globals ( p_phf_si_type             =>    p_phf_si_type
                       , p_start_date              =>    l_start_date
                       , p_end_date                =>    l_end_date
                       , p_legal_employer_id       =>    p_legal_employer_id
                       , p_business_group_id       =>    p_business_group_id
                       , p_contribution_area       =>    p_contribution_area
                       , p_contribution_year       =>    p_contribution_year
                       , p_filling_date            =>    null
                       , p_report_type             =>    'CB'
                       );
    --

    hr_utility.set_location('China : Check whether Legal Employer has fixed amount for given Contribution Area ', 85);

    --
    -- Bug 3593118
    -- Enterprise Annuity - Added new parameter p_assignment_id in call to
    -- get_phf_si_rates
    --

    l_message := pay_cn_deductions.get_phf_si_rates
                               (p_assignment_id     => NULL
			       ,p_business_group_id => p_business_group_id
                               ,p_contribution_area => p_contribution_area
                               ,p_phf_si_type       => p_phf_si_type
                               ,p_employer_id       => p_legal_employer_id
                               ,p_hukou_type        => NULL
                               ,p_effective_date    => l_start_date
                               --
                               ,p_ee_rate_type      => l_ee_rate_type
                               ,p_er_rate_type      => l_er_rate_type
                               ,p_ee_rate           => l_ee_rate
                               ,p_er_rate           => l_er_rate
			       ,p_ee_thrhld_rate    => l_ee_thrhld_rate  /* For bug 6828199 */
			       ,p_er_thrhld_rate    => l_er_thrhld_rate  /* For bug 6828199 */
                               ,p_ee_rounding_method   => l_ee_rounding_method
                               ,p_er_rounding_method   => l_er_rounding_method
                               );

    IF l_message = 'SUCCESS' THEN
    --
      IF (l_er_rate_type <> 'PERCENTAGE') OR (l_ee_rate_type <> 'PERCENTAGE') THEN
      --
        hr_utility.set_location('China : Legal Employer has fixed amount for given Contribution Area ', 90);
        RETURN;
      --
      END IF;
    --
    END IF;

    hr_utility.set_location('China : Calling -> ben_ext_thread.process', 100);


    -- Call the Extract Process
    --
    ben_ext_thread.process ( errbuf                => l_errbuf
                           , retcode               => l_retcode
                           , p_benefit_action_id   => NULL
                           , p_ext_dfn_id          => l_extract_def_id
                           , p_effective_date      => TO_CHAR(l_end_date,'yyyy/mm/dd')
                           , p_business_group_id   => p_business_group_id
                           );

    -- Delete the globals stored in the table
    --
    delete_globals;

    hr_utility.set_location('China : Leaving -> '|| l_proc_name, 120);

  EXCEPTION
    WHEN OTHERS THEN
      delete_globals;
      IF csr_extract_def_id%ISOPEN THEN
         CLOSE csr_extract_def_id;
      END IF;

      IF csr_start_month%ISOPEN THEN
         CLOSE csr_start_month;
      END IF;

      hr_utility.set_location('China Exception, Leaving: '||l_proc_name, 130);
      RAISE;
  END cb_extract_process;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CA_EXTRACT_PROCESS                                    --
  -- Type           : PROCEDURE                                             --
  -- Access         : Public                                                --
  -- Description    : Procedure for CA Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_phf_si_type        VARCHAR2                         --
  --                  p_legal_employer_id  NUMBER                           --
  --                  p_contribution_area  VARCHAR2                         --
  --                  p_contribution_year  VARCHAR2                         --
  --                  p_business_group_id  NUMBER                           --
  --           OUT  : errbuf               VARCHAR2                         --
  --                  retcode              VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  ----------------------------------------------------------------------------
  PROCEDURE ca_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                              , retcode              OUT  NOCOPY VARCHAR2
                              , p_phf_si_type        IN   VARCHAR2
                              , p_legal_employer_id  IN   NUMBER
                              , p_contribution_area  IN   VARCHAR2
                              , p_contribution_year  IN   VARCHAR2
                              , p_contribution_month IN   VARCHAR2
                              , p_business_group_id  IN   NUMBER
                              )
  IS
  --

    -- Declare local Variables
    --
    l_extract_def_id       NUMBER;
    l_errbuf               VARCHAR2(3000);
    l_retcode              VARCHAR2(2000);
    l_proc_name            VARCHAR2(150);

    l_start_date           DATE;
    l_end_date             DATE;

    --

    -- Cursor to fetch extract definition id of 'CA Extract'
    --
    CURSOR csr_extract_def_id
    IS
    --
      SELECT ed.ext_dfn_id
      FROM   ben_ext_dfn ed, hr_lookups hrl, per_business_groups bg
      WHERE  ((bg.business_group_id = ed.business_group_id)
             OR  (bg.legislation_code = ed.legislation_code)
             OR  (ed.business_group_id is null and ed.legislation_code is null))
      AND    bg.business_group_id = p_business_group_id
      AND    ed.data_typ_cd = hrl.lookup_code
      AND    hrl.lookup_type = 'BEN_EXT_DATA_TYP'
      AND    substr(ed.NAME,1,240) = 'CA Extract';


  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.ca_extract_process';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    hr_utility.set_location('China : Before csr_extract_def_id ', 20);

    -- Fetch Extract Definition Id
    --
    OPEN csr_extract_def_id;
    FETCH csr_extract_def_id
      INTO l_extract_def_id;

    -- If Extract Definition does not exist return
    IF csr_extract_def_id%NOTFOUND THEN
    --
      hr_utility.set_location('China : Extract Definition not Found ' , 30);
      CLOSE csr_extract_def_id;
      RETURN;
    --
    END IF;
    --

    CLOSE csr_extract_def_id;

    hr_utility.set_location('China : After csr_extract_def_id ', 40);

    hr_utility.set_location('China : l_extract_def_id      -> '    || l_extract_def_id    , 45);
    hr_utility.set_location('China : p_phf_si_type         -> '    || p_phf_si_type       , 45);
    hr_utility.set_location('China : p_start_date          -> '    || l_start_date        , 45);
    hr_utility.set_location('China : p_end_date            -> '    || l_end_date          , 45);
    hr_utility.set_location('China : p_legal_employer_id   -> '    || p_legal_employer_id , 45);
    hr_utility.set_location('China : p_business_group_id   -> '    || p_business_group_id , 45);
    hr_utility.set_location('China : p_contribution_area   -> '    || p_contribution_area , 45);
    hr_utility.set_location('China : p_contribution_year   -> '    || p_contribution_year , 45);

    -- Calculation of the start_date and end_date

    l_start_date := to_date( ('01-'||p_contribution_month||'-'||p_contribution_year) , 'DD-MM-YYYY');
    hr_utility.set_location('China : l_start_date -> '|| l_start_date , 50);

    l_end_date   := LAST_DAY(l_start_date);
    hr_utility.set_location('China : l_end_date -> '|| l_end_date , 50);

    -- Set Global Variables
    --

    initialize_globals ( p_phf_si_type             =>    p_phf_si_type
                       , p_start_date              =>    l_start_date
                       , p_end_date                =>    l_end_date
                       , p_legal_employer_id       =>    p_legal_employer_id
                       , p_business_group_id       =>    p_business_group_id
                       , p_contribution_area       =>    p_contribution_area
                       , p_contribution_year       =>    p_contribution_year
                       , p_filling_date            =>    null
                       , p_report_type             =>    'CA'
		       );

    hr_utility.set_location('China : Calling -> ben_ext_thread.process', 60);

    -- Call the Extract Process
    --
    ben_ext_thread.process ( errbuf      => l_errbuf
                           , retcode     => l_retcode
                           , p_benefit_action_id   => NULL
                           , p_ext_dfn_id          => l_extract_def_id
                           , p_effective_date      => to_char(l_end_date,'yyyy/mm/dd')
                           , p_business_group_id   => p_business_group_id
                           );

    -- Delete the globals stored in the table
    --
    delete_globals;

    hr_utility.set_location('China : Leaving -> '|| l_proc_name, 70);
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      delete_globals;
      IF csr_extract_def_id%ISOPEN THEN
         CLOSE csr_extract_def_id;
      END IF;

      hr_utility.set_location('China Exception, Leaving: '||l_proc_name, 80);
      RAISE;

  END ca_extract_process;

  ----------------------------------------------------------------------------
  -- Name           : EM_EXTRACT_PROCESS                                    --
  -- Access         : Public                                                --
  -- Description    : Procedure for EM Extract                              --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN :  p_phf_si_type          VARCHAR2                      --
  --                   p_legal_employer_id    NUMBER                        --
  --                   p_contribution_area    VARCHAR2                      --
  --                   p_contribution_year    VARCHAR2                      --
  --                   p_contribution_month   VARCHAR2                      --
  --                   p_business_group_id    NUMBER                        --
  --                   p_filling_date         VARCHAR2                      --
  --           OUT  :  errbuf                 VARCHAR2                      --
  --                   retcode                VARCHAR2                      --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this procedure                   --
  ----------------------------------------------------------------------------
  PROCEDURE em_extract_process( errbuf               OUT  NOCOPY VARCHAR2
                              , retcode              OUT  NOCOPY VARCHAR2
                              , p_phf_si_type        IN   VARCHAR2
                              , p_legal_employer_id  IN   NUMBER
                              , p_contribution_area  IN   VARCHAR2
                              , p_contribution_year  IN   VARCHAR2
                              , p_contribution_month IN   VARCHAR2
                              , p_business_group_id  IN   NUMBER
                              , p_filling_date       IN   VARCHAR2
                              )
  IS
  --

    -- Declare local Variables
    --
    l_extract_def_id NUMBER;
    l_errbuf       VARCHAR2(3000);
    l_retcode      VARCHAR2(2000);
    l_proc_name    VARCHAR2(150);

    l_start_date         DATE;
    l_end_date           DATE;
    l_filling_date       DATE;

    -- Cursor to fetch extract definition id of 'EM Extract'
    --
    CURSOR csr_extract_def_id
    IS
    --
      SELECT ed.ext_dfn_id
      FROM   ben_ext_dfn ed, hr_lookups hrl, per_business_groups bg
      WHERE  ((bg.business_group_id = ed.business_group_id)
      OR  (bg.legislation_code = ed.legislation_code)
      OR  (ed.business_group_id is null and ed.legislation_code is null))
      AND    bg.business_group_id = p_business_group_id
      AND    ed.data_typ_cd = hrl.lookup_code
      AND    hrl.lookup_type = 'BEN_EXT_DATA_TYP'
      AND    substr(ed.NAME,1,240) = 'EM Extract';
    --

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.em_extract_process';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    hr_utility.set_location('China : Before csr_extract_def_id ', 20);

    -- Fetch Extract Definition Id
    --
    OPEN csr_extract_def_id;
    FETCH csr_extract_def_id
      INTO l_extract_def_id;

    -- If Extract Definition does not exist return
    IF csr_extract_def_id%NOTFOUND THEN
    --
      hr_utility.set_location('China : Extract Definition not Found ' , 30);
      CLOSE csr_extract_def_id;
      RETURN;
    --
    END IF;
    --
    -- Bug 3448316 caused this change
    l_filling_date:=fnd_date.canonical_to_date(p_filling_date);
    --

    hr_utility.set_location('China : p_extract_def_id      -> '    || l_extract_def_id    , 40);
    hr_utility.set_location('China : p_phf_si_type         -> '    || p_phf_si_type       , 40);
    hr_utility.set_location('China : p_start_date          -> '    || l_start_date        , 40);
    hr_utility.set_location('China : p_end_date            -> '    || l_end_date          , 40);
    hr_utility.set_location('China : p_legal_employer_id   -> '    || p_legal_employer_id , 40);
    hr_utility.set_location('China : p_business_group_id   -> '    || p_business_group_id , 40);
    hr_utility.set_location('China : p_filling_date        -> '    || l_filling_date      , 40);
    hr_utility.set_location('China : p_contribution_area   -> '    || p_contribution_area , 40);
    hr_utility.set_location('China : p_contribution_year   -> '    || p_contribution_year , 40);

    -- Calculation of the start_date and end_date

    l_start_date := TO_DATE( ('01-'||p_contribution_month||'-'||p_contribution_year) , 'DD-MM-YYYY');
    hr_utility.set_location('China l_start_date -> '|| l_start_date , 50);

    l_end_date   := LAST_DAY(l_start_date);
    hr_utility.set_location('China l_end_date -> '|| l_end_date , 50);

    -- Set Global Variables
    --

    initialize_globals ( p_phf_si_type             =>    p_phf_si_type
                       , p_start_date              =>    l_start_date
                       , p_end_date                =>    l_end_date
                       , p_legal_employer_id       =>    p_legal_employer_id
                       , p_business_group_id       =>    p_business_group_id
                       , p_contribution_area       =>    p_contribution_area
                       , p_contribution_year       =>    p_contribution_year
                       , p_filling_date            =>    l_filling_date
                       -- bug 3448316 caused change from p_filling_date to l_filling_date
                       , p_report_type             =>    'EM'

		       );
    hr_utility.set_location('China : Calling -> ben_ext_thread.process', 60);

    ben_ext_thread.process ( errbuf                => l_errbuf
                           , retcode               => l_retcode
                           , p_benefit_action_id   => NULL
                           , p_ext_dfn_id          => l_extract_def_id
                           , p_effective_date      => TO_CHAR(l_end_date,'yyyy/mm/dd')
                           , p_business_group_id   => p_business_group_id
                           );

    -- Delete the globals stored in the table
    --
    delete_globals;

    hr_utility.set_location('China : Leaving -> '|| l_proc_name, 70);
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      delete_globals;
      IF csr_extract_def_id%ISOPEN THEN
         CLOSE csr_extract_def_id;
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 80);
      RAISE;
  --
  END em_extract_process;

  ----------------------------------------------------------------------------
  -- Name           : CB_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for CB Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT : p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   03-Feb-2004   saikrish  Added check for assignment actions(3411273)
  ----------------------------------------------------------------------------
  FUNCTION cb_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2
  IS
  --

    l_expat_indicator     per_all_people_f.per_information8%TYPE;
    l_cont_area           hr_soft_coding_keyflex.segment21%TYPE;
    l_assg_legal_employer NUMBER;
    l_proc_name           VARCHAR2(150);
    l_return_value        CHAR(1);
    l_value               CHAR(1);

    l_phf_si_type         VARCHAR2(50);
    l_start_date          DATE;
    l_end_date            DATE;
    l_legal_employer_id   NUMBER;
    l_business_group_id   NUMBER;
    l_contribution_area   VARCHAR2(30);
    l_contribution_year   VARCHAR2(30);
    l_filling_date        DATE;
    l_report_type         VARCHAR2(3);
    l_element_name        pay_element_types_f.element_name%TYPE;

    l_mod_start_date      DATE;
    l_mod_end_date        DATE;

    -- Cursor to return Expatriate Indicator and Legal Employer
    --
    CURSOR csr_valid_assignment( p_assignment_id IN VARCHAR2
                                ,p_start_date    IN DATE
                               )
    IS
    --
      SELECT pap.per_information8                          exp_indicator
            ,fnd_number.canonical_to_number(hsck.segment1) Legal_Employer
      FROM   per_all_assignments_f  paa
            ,per_all_people_f       pap
            ,hr_soft_coding_keyflex hsck
      WHERE  paa.assignment_id          = p_assignment_id
      AND    paa.business_group_id      = p_business_group_id
      AND    paa.person_id              = pap.person_id
      AND    paa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
      AND    paa.assignment_type        = 'E'
      AND    p_start_date               BETWEEN pap.effective_start_date
                                        AND     pap.effective_end_date
      AND    p_start_date               BETWEEN paa.effective_start_date
                                        AND     paa.effective_end_date;
    --
  --
  BEGIN
  --
    l_expat_indicator  := 'Y';
    l_proc_name        := 'pay_cn_ext.cb_criteria_profile';
    l_return_value     := 'N';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);


    hr_utility.set_location('China : p_assignment_id     -> '    || p_assignment_id     , 20);
    hr_utility.set_location('China : p_business_group_id -> '    || p_business_group_id , 20);
    hr_utility.set_location('China : p_date_earned       -> '    || p_date_earned       , 20);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- Check whether the assignment's business group id is same as the concurrent program
    -- business group id. If not return 'N'
    --
    IF (p_business_group_id <> l_business_group_id) THEN
    --
      hr_utility.set_location('China : Business Group does not match'   , 30);
      RETURN l_return_value;
    --
    END IF;
    --

    OPEN csr_valid_assignment(p_assignment_id, l_start_date);
    FETCH csr_valid_assignment
      INTO l_expat_indicator,l_assg_legal_employer  ;

    -- Check for valid assignment
    --
    IF csr_valid_assignment%NOTFOUND THEN
    -- Assignment is not live
      hr_utility.set_location('China : Assignment not valid'   , 40);
      CLOSE csr_valid_assignment;
      RETURN l_return_value;
    --
    ELSE
    --
      -- Assignment is valid
      -- If the Expatriate Indicator is 'Y' or Assignment's
      -- Legal Employer is not same as the one submitted in Concurrent Request
      -- then the assignment is not be included
      --
      IF (l_expat_indicator = 'Y') OR  (l_assg_legal_employer <> l_legal_employer_id) THEN
      --
        hr_utility.set_location('China : Legal Employer/Expat Ind mismatch', 50);
        CLOSE csr_valid_assignment;
        RETURN l_return_value;
      --
      END IF;
      --
    --
    END IF;
    --
    CLOSE csr_valid_assignment;

    -- 3411840, Check the assignment's Override Contribution area is same as the concurrent parameter
    l_element_name := get_element_name(l_phf_si_type);
    hr_utility.set_location('China : l_element_name   ->'|| l_element_name, 60);

    l_cont_area := pay_cn_ext.get_override_sic_code(l_element_name,p_assignment_id,p_date_earned);
    hr_utility.set_location('China : l_cont_area   ->'|| l_cont_area, 60);

    IF l_cont_area IS NULL THEN
       -- Check the assignment's Contribution area is same as the concurrent parameter
       -- Set the contexts
       pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);
       pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));

       -- Run the DBI
       l_cont_area := pay_balance_pkg.run_db_item('SCL_ASG_CN_SIC_AREA',p_business_group_id,'CN');

       hr_utility.set_location('China : l_cont_area       -> '|| l_cont_area, 80);

    END IF;

    hr_utility.set_location('China : l_cont_area   ->'|| l_cont_area, 60);
    hr_utility.set_location('China : l_contribution_area   ->'|| l_contribution_area, 60);

    IF l_cont_area <> l_contribution_area THEN
    --
      hr_utility.set_location('China : Cont Area does not match'   , 90);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Check whether the element entries exist for the PHF/SI type given
    -- in concurrent request
    --
    -- Bug 3415164
    -- Using Start Date as Effective Date
    --
    l_value := pay_cn_ext.get_element_entry(p_assignment_id, p_business_group_id,l_start_date,l_phf_si_type);

    -- If element entry for the given PHF/SI Type does not exist for the assignment
    -- then the assignment is not eligible
    IF l_value = 'N' THEN
    --
      hr_utility.set_location('China : Element Entry not found ', 70);
      RETURN l_return_value;
    --
    END IF;

    --Bug 3411273, Check whether assignment action exist for PREV_MONTH
    hr_utility.set_location('China : Check for PREV_MONTH ', 90);

    l_mod_start_date := TRUNC(TRUNC(l_start_date,'MM')-1,'MM');
    l_mod_end_date   := LAST_DAY(l_mod_start_date);

    hr_utility.set_location('China : PREV_MONTH, l_mod_start_date '|| l_mod_start_date , 90);
    hr_utility.set_location('China : PREV_MONTH, l_mod_end_date '|| l_mod_end_date , 90);

    l_value := pay_cn_ext.get_assignment_action(p_assignment_id, p_business_group_id,l_mod_start_date,l_mod_end_date);
    IF l_value = 'N' THEN
      hr_utility.set_location('China : Assignment Actions not found ', 90);
      RETURN l_return_value;
    END IF;


    -- Assignment should be included
    l_return_value := 'Y';
    hr_utility.set_location('China : l_return_value       -> '    || l_return_value       , 110);

    hr_utility.set_location('China : Leaving -> '|| l_proc_name , 120);

    RETURN l_return_value;

  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_valid_assignment%ISOPEN THEN
      --
        CLOSE csr_valid_assignment;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 130);
      RAISE;
--
END cb_criteria_profile;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : CA_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for CA Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT:  p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   03-Feb-2004   saikrish  Added check for assignment actions(3411273)
  ----------------------------------------------------------------------------
  FUNCTION ca_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2
  IS
  --

    l_expat_indicator     per_all_people_f.per_information8%TYPE;
    l_cont_area           hr_soft_coding_keyflex.segment21%TYPE;
    l_assg_legal_employer NUMBER;
    l_proc_name           VARCHAR2(150);
    l_return_value        CHAR(1);
    l_value               CHAR(1) ;

    l_phf_si_type         VARCHAR2(50);
    l_start_date          DATE;
    l_end_date            DATE;
    l_legal_employer_id   NUMBER;
    l_business_group_id   NUMBER;
    l_contribution_area   VARCHAR2(30);
    l_contribution_year   VARCHAR2(30);
    l_filling_date        DATE;
    l_report_type         VARCHAR2(3);
    l_element_name        pay_element_types_f.element_name%TYPE;

    -- Cursor to return Expatriate Indicator and Legal Employer
    --
    -- Bug 3415164
    -- Changed the cursor to use p_end_date
    --
    CURSOR csr_valid_assignment( p_assignment_id IN VARCHAR2
                                ,p_end_date      IN DATE
                               )
    IS
    --
      SELECT pap.per_information8                          exp_indicator
            ,fnd_number.canonical_to_number(hsck.segment1) Legal_Employer
      FROM   per_all_assignments_f  paa
            ,per_all_people_f       pap
            ,hr_soft_coding_keyflex hsck
      WHERE  paa.assignment_id          = p_assignment_id
      AND    paa.business_group_id      = p_business_group_id
      AND    paa.person_id              = pap.person_id
      AND    paa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
      AND    paa.assignment_type        = 'E'
      AND    p_end_date                 BETWEEN pap.effective_start_date
                                        AND     pap.effective_end_date
      AND    p_end_date                 BETWEEN paa.effective_start_date
                                        AND     paa.effective_end_date;
    --

  --
  BEGIN
  --
    l_expat_indicator  := 'Y';
    l_return_value     := 'N';
    l_proc_name   := 'pay_cn_ext.ca_criteria_profile';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    hr_utility.set_location('China : p_assignment_id     -> '    || p_assignment_id     , 20);
    hr_utility.set_location('China : p_business_group_id -> '    || p_business_group_id , 20);
    hr_utility.set_location('China : p_date_earned       -> '    || p_date_earned       , 20);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- Check whether the assignment's business group id is same as the concurrent program
    -- business group id. If not return 'N'
    --
    IF (p_business_group_id <> l_business_group_id) THEN
    --
      hr_utility.set_location('China : Business Group does not match'   , 30);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Check for valid assignment
    -- Bug 3415164
    -- Passing l_end_date instead of l_start_date
    --
    OPEN csr_valid_assignment(p_assignment_id, l_end_date);
    FETCH csr_valid_assignment
      INTO l_expat_indicator,l_assg_legal_employer  ;

    IF csr_valid_assignment%NOTFOUND THEN
    -- Assignment is not live
      hr_utility.set_location('China : Assignment not valid'   , 40);
      CLOSE csr_valid_assignment;
      RETURN l_return_value;
    --
    ELSE
    --
      -- Assignment is valid
      -- If the Expatriate Indicator is 'Y' or Assignment's
      -- Legal Employer is not same as the one submitted in Concurrent Request
      -- then the assignment is not be included
      --
      IF (l_expat_indicator = 'Y') OR  (l_assg_legal_employer <> l_legal_employer_id) THEN
      --
        hr_utility.set_location('China : Legal Employer/Expat Ind mismatch', 50);
        CLOSE csr_valid_assignment;
        RETURN l_return_value;
      --
      END IF;
      --
    --
    END IF;
    --
    CLOSE csr_valid_assignment;

    -- 3411840, Check the assignment's Override Contribution area is same as the concurrent parameter
    l_element_name := get_element_name(l_phf_si_type);

    hr_utility.set_location('China : l_element_name    ->'|| l_element_name , 90);

    l_cont_area := pay_cn_ext.get_override_sic_code(l_element_name,p_assignment_id,p_date_earned);

    hr_utility.set_location('China : l_cont_area    ->'|| l_cont_area, 90);

    IF l_cont_area IS NULL THEN
       -- Check the assignment's Contribution area is same as the concurrent parameter
       -- Set the contexts
       pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);
       pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));

       -- Run the DBI
       l_cont_area := pay_balance_pkg.run_db_item('SCL_ASG_CN_SIC_AREA',p_business_group_id,'CN');

       hr_utility.set_location('China : l_cont_area       -> '|| l_cont_area, 80);

    END IF;

    hr_utility.set_location('China : l_cont_area    ->'|| l_cont_area, 90);
    hr_utility.set_location('China : l_contribution_area    ->'|| l_contribution_area , 90);

    IF l_cont_area <> l_contribution_area THEN
    --
      hr_utility.set_location('China : Cont Area does not match'   , 90);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Check whether the element entries exist for the PHF/SI type given
    -- in concurrent request
    -- Bug 3415164
    -- Using End Date as effective date
    --
    l_value := pay_cn_ext.get_element_entry(p_assignment_id, p_business_group_id,l_end_date,l_phf_si_type);

    -- If element entry for the given PHF/SI Type does not exist for the assignment
    -- then the assignment is not eligible
    IF l_value = 'N' THEN
    --
      hr_utility.set_location('China : Element Entry not found ', 70);
      RETURN l_return_value;
    --
    END IF;

    -- Bug 3411273, Check whether assignment action ids exist
    l_value := pay_cn_ext.get_assignment_action(p_assignment_id, p_business_group_id,l_start_date,l_end_date);
    IF l_value = 'N' THEN
      hr_utility.set_location('China : Assignment Actions not found ', 80);
      RETURN l_return_value;
    END IF;

    -- Assignment should be included
    l_return_value :='Y';
    hr_utility.set_location('China : l_return_value       -> '    || l_return_value       , 110);

    hr_utility.set_location('China : Leaving -> '|| l_proc_name , 120);

    RETURN l_return_value;
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_valid_assignment%ISOPEN THEN
      --
        CLOSE csr_valid_assignment;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 80);
      RAISE;
  --
  END ca_criteria_profile;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : EM_CRITERIA_PROFILE                                   --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to select the assignments to be extracted    --
  --                  for EM Report                                         --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_date_earned        DATE                             --
  --            OUT:  p_warning_message    VARCHAR2                         --
  --                  p_error_message      VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   13-Jan-2004   Bramajey  Changed data type of l_element_name      --
  -- 1.2   20-Feb-2004   bramajey  Introduced cursor csr_prev_acct_status   --
  --                               for bug 3456501                          --
  ----------------------------------------------------------------------------
  FUNCTION em_criteria_profile ( p_assignment_id      IN VARCHAR2
                               , p_business_group_id  IN NUMBER
                               , p_date_earned        IN DATE
                               , p_warning_message    OUT NOCOPY VARCHAR2
                               , p_error_message      OUT NOCOPY VARCHAR2
                               )
  RETURN VARCHAR2
  IS
  --

    l_element_name           pay_element_types_f.element_name%TYPE;
    l_acct_status            VARCHAR2(50);
    l_prev_acct_status       VARCHAR2(50);
    l_reason_of_change       VARCHAR2(10);
    l_expat_indicator        per_all_people_f.per_information8%TYPE;
    l_cont_area              hr_soft_coding_keyflex.segment21%TYPE;
    l_assg_legal_employer    NUMBER;
    l_proc_name              VARCHAR2(150);
    l_return_value           CHAR(1);
    l_value                  CHAR(1);

    l_phf_si_type            VARCHAR2(50);
    l_start_date             DATE;
    l_end_date               DATE;
    l_legal_employer_id      NUMBER;
    l_business_group_id      NUMBER;
    l_contribution_area      VARCHAR2(30);
    l_contribution_year      VARCHAR2(30);
    l_filling_date           DATE;
    l_report_type            VARCHAR2(3);

	-- Bug 3456501
	-- Included additional date effective check

    -- Cursor to get the account status of the assignment
    --
    CURSOR csr_acct_status(p_element_name VARCHAR2
                          ,p_input_value  VARCHAR2
                          ,p_start_date   DATE
                          ,p_end_date     DATE)
    IS
    --
      SELECT  eev.screen_entry_value
      FROM    pay_element_entry_values_f               eev
             ,pay_element_entries_f                    pee
             ,pay_element_links_f                      pil
             ,pay_input_values_f                       piv
             ,pay_element_types_f                      pet
      WHERE   pet.element_name          = p_element_name
      AND     pet.element_type_id       = piv.element_type_id
      AND     piv.name                  = p_input_value
      AND     pet.element_type_id       = pil.element_type_id
      AND     pil.element_link_id       = pee.element_link_id
      AND     pee.assignment_id         = p_assignment_id
      AND     pee.element_entry_id      = eev.element_entry_id
      AND     eev.input_value_id        = piv.input_value_id
      AND     p_date_earned             BETWEEN pet.effective_start_date
                                        AND     pet.effective_end_date
      AND     p_date_earned             BETWEEN piv.effective_start_date
                                        AND     piv.effective_end_date
      AND     p_date_earned             BETWEEN pil.effective_start_date
                                        AND     pil.effective_end_date
      AND     p_date_earned             BETWEEN pee.effective_start_date
                                        AND     pee.effective_end_date
      AND     p_date_earned             BETWEEN eev.effective_start_date
                                        AND     eev.effective_end_date
      AND     eev.effective_start_date  BETWEEN p_start_date
                                        AND     p_end_date
      AND     nvl(pee.entry_type, 'E')  = 'E';

    --

    -- Bug 3456501
    -- Cursor to get the account status of the assignment
    -- for previous month
    --
    CURSOR csr_prev_acct_status(p_element_name    VARCHAR2
                               ,p_input_value     VARCHAR2
                               ,p_effective_date  DATE)
    IS
    --
      SELECT  eev.screen_entry_value
      FROM    pay_element_entry_values_f               eev
             ,pay_element_entries_f                    pee
             ,pay_element_links_f                      pil
             ,pay_input_values_f                       piv
             ,pay_element_types_f                      pet
      WHERE   pet.element_name          = p_element_name
      AND     pet.element_type_id       = piv.element_type_id
      AND     piv.name                  = p_input_value
      AND     pet.element_type_id       = pil.element_type_id
      AND     pil.element_link_id       = pee.element_link_id
      AND     pee.assignment_id         = p_assignment_id
      AND     pee.element_entry_id      = eev.element_entry_id
      AND     eev.input_value_id        = piv.input_value_id
      AND     p_effective_date          BETWEEN pet.effective_start_date
                                        AND     pet.effective_end_date
      AND     p_effective_date          BETWEEN piv.effective_start_date
                                        AND     piv.effective_end_date
      AND     p_effective_date          BETWEEN pil.effective_start_date
                                        AND     pil.effective_end_date
      AND     p_effective_date          BETWEEN pee.effective_start_date
                                        AND     pee.effective_end_date
      AND     p_effective_date          BETWEEN eev.effective_start_date
                                        AND     eev.effective_end_date
      AND     nvl(pee.entry_type, 'E')  = 'E';
    --

    -- Cursor to return Expatriate Indicator and Legal Employer
    --
    -- Bug 3415164
    -- Changed the cursor to use p_end_date
    --
    CURSOR csr_valid_assignment( p_assignment_id IN VARCHAR2
                                ,p_end_date      IN DATE
                               )
    IS
    --
      SELECT pap.per_information8                          exp_indicator
            ,fnd_number.canonical_to_number(hsck.segment1) Legal_Employer
      FROM   per_all_assignments_f  paa
            ,per_all_people_f       pap
            ,hr_soft_coding_keyflex hsck
      WHERE  paa.assignment_id          = p_assignment_id
      AND    paa.business_group_id      = p_business_group_id
      AND    paa.person_id              = pap.person_id
      AND    paa.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
      AND    paa.assignment_type        = 'E'
      AND    p_end_date                 BETWEEN paa.effective_start_date
                                        AND     paa.effective_end_date
      AND    p_end_date                 BETWEEN pap.effective_start_date
                                        AND     pap.effective_end_date;

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.em_criteria_profile';
    l_expat_indicator  := 'Y';
    l_return_value     := 'N';

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);

    hr_utility.set_location('China : p_assignment_id     -> '    || p_assignment_id     , 20);
    hr_utility.set_location('China : p_business_group_id -> '    || p_business_group_id , 20);
    hr_utility.set_location('China : p_date_earned       -> '    || p_date_earned       , 20);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- Check whether the assignment's business group id is same as the concurrent program
    -- business group id. If not return 'N'
    IF (p_business_group_id <> l_business_group_id) THEN
    --
      hr_utility.set_location('China : business grp mismtach '    || l_end_date   , 10);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Check for valid assignment
    -- Bug 3415164
    -- Passing l_end_date instead of l_start_date
    OPEN csr_valid_assignment(p_assignment_id, l_end_date);
    FETCH csr_valid_assignment
      INTO l_expat_indicator,l_assg_legal_employer  ;


    IF csr_valid_assignment%NOTFOUND THEN
    --
    -- Assignment is not live
      hr_utility.set_location('China : Assignment not valid'   , 40);
      CLOSE csr_valid_assignment;
      RETURN l_return_value;
    --
    ELSE
    --
      -- Assignment is valid
      -- If the Expatriate Indicator is 'Y' or Assignment's
      -- Legal Employer is not same as the one submitted in Concurrent Request
      -- then the assignment is not be included
      --
      IF (l_expat_indicator = 'Y') OR  (l_assg_legal_employer <> l_legal_employer_id) THEN
      --
        hr_utility.set_location('China : Legal Employer/Expat Ind mismatch', 50);
        CLOSE csr_valid_assignment;
        RETURN l_return_value;
      --
      END IF;
      --
    --
    END IF;
    --
    CLOSE csr_valid_assignment;

    -- 3411840, Check the assignment's Override Contribution area is same as the concurrent parameter
    l_element_name := get_element_name(l_phf_si_type);
    hr_utility.set_location('China : l_element_name    ->'|| l_element_name, 60);

    l_cont_area := pay_cn_ext.get_override_sic_code(l_element_name,p_assignment_id,p_date_earned);
    hr_utility.set_location('China : l_cont_area     ->'|| l_cont_area, 60);

    IF l_cont_area IS NULL THEN
       -- Check the assignment's Contribution area is same as the concurrent parameter
       -- Set the contexts
       pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);
       pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));

       -- Run the DBI
       l_cont_area := pay_balance_pkg.run_db_item('SCL_ASG_CN_SIC_AREA',p_business_group_id,'CN');

       hr_utility.set_location('China : l_cont_area       -> '|| l_cont_area, 70);

    END IF;

    hr_utility.set_location('China : l_cont_area      ->'|| l_cont_area, 80);
    hr_utility.set_location('China : l_contribution_area      ->'|| l_contribution_area, 80);

    IF l_cont_area <> l_contribution_area THEN
    --
      hr_utility.set_location('China : Cont Area does not match'   , 85);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Check whether the element entries exist for the PHF/SI type given
    -- in concurrent request
    --
    l_value := pay_cn_ext.get_element_entry(p_assignment_id, p_business_group_id,l_end_date,l_phf_si_type);

    -- If element entry for the given PHF/SI Type does not exist for the assignment
    -- then the assignment is not eligible
    IF l_value = 'N' THEN
    --
      hr_utility.set_location('China : Element Entry not found ', 90);
      RETURN l_return_value;
    --
    END IF;
    --

    -- Code to check the account status
    --

    -- Get the element name
    l_element_name := get_element_name(l_phf_si_type);

    -- Get the account status
    --
    OPEN   csr_acct_status( l_element_name, 'Account Status',l_start_date,l_end_date);
    FETCH  csr_acct_status
      INTO l_acct_status;

    -- Check whether account status exist
    --
    IF csr_acct_status%NOTFOUND THEN
    --
      hr_utility.set_location('China :  Acct status not found'    || l_end_date   , 100);
      CLOSE csr_acct_status;
      RETURN l_return_value;
    --
    -- Check whether account status is OPEN, CLOSED, TRANSFER IN or TRANSFER OUT
    --
    ELSIF l_acct_status IN ('OPEN','CLOSED','TRANSFER IN','TRANSFER OUT') THEN
    --
      CLOSE csr_acct_status;
      -- Bug 3456501 starts
      -- Check whether Current month's account status is same as previous month
      OPEN   csr_prev_acct_status( l_element_name, 'Account Status',(l_start_date-1));
      FETCH  csr_prev_acct_status
        INTO l_prev_acct_status;

      IF ((csr_prev_acct_status%FOUND) AND (l_prev_acct_status = l_acct_status)) THEN
      --
      -- Account status is same as previous month. Hence no need to report this
      -- assignment
        hr_utility.set_location('China :  Acct status same as prev month'    || l_end_date   , 110);
        CLOSE csr_prev_acct_status;
	    RETURN l_return_value;
      --
      END IF;

      CLOSE csr_prev_acct_status;
      -- Bug 3456501 ends

      -- Check whether the reason of change is 'Others'
      --

      OPEN   csr_acct_status( l_element_name, 'Status Change Reason',l_start_date,l_end_date);
      FETCH  csr_acct_status
        INTO l_reason_of_change;
      hr_utility.set_location('China : Reason Of Change' ||l_reason_of_change   , 115);
      --
      IF (l_reason_of_change IS NULL) OR (l_reason_of_change = '11') THEN
      --
        hr_utility.set_location('China :Reason of change is Others '   , 120);
        l_return_value := 'N';
	CLOSE csr_acct_status;
	RETURN l_return_value;
      --
      ELSE
      --
        hr_utility.set_location('China : Valid acct Status'    , 125);
        l_return_value := 'Y';
        CLOSE csr_acct_status;
      --
      END IF;
    --
    ELSE
    --
      -- If not
      -- Check whether the reason of change is 'Death of Employee'
      --
      CLOSE csr_acct_status;
      OPEN   csr_acct_status( l_element_name, 'Status Change Reason',l_start_date,l_end_date);
      FETCH  csr_acct_status
        INTO l_reason_of_change;
      hr_utility.set_location('China :  Reason Of Change' ||l_reason_of_change   , 130);
      --
      IF l_reason_of_change = '10' THEN
      --
        hr_utility.set_location('China :  Dead '   , 140);
        l_return_value := 'Y';
      --
      ELSE
      --
         l_return_value := 'N';
         CLOSE csr_acct_status;
         RETURN l_return_value;

      --
      END IF;
      --
      CLOSE csr_acct_status;
    --
    END IF;
    --

    -- Assignment should be included
    l_return_value :='Y';
    hr_utility.set_location('China : l_return_value       -> '    || l_return_value       , 150);
    hr_utility.set_location('China : China Leaving        -> '    || l_proc_name , 160);

    RETURN l_return_value;
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_valid_assignment%ISOPEN THEN
      --
        CLOSE csr_valid_assignment;
      --
      END IF;
      IF csr_acct_status%ISOPEN THEN
      --
         CLOSE csr_acct_status;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 180);
      RAISE;
  --
  END em_criteria_profile;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_EMPLOYER_INFO                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to get employer information based on the     --
  --                  info type                                             --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_info_type          VARCHAR2                         --
  --                  p_assignment_id      NUMBER                           --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   06-Jul-2004   sshankar  Modified code as required to support     --
  --                               Enterprise Annuity. (Bug 3593118)        --
  -- 1.2   15-Sep-2004   snekkala  Modified code to fetch hukuo type        --
  -- 1.3   05-Oct-2004   snekkala  Modified the datatype from VARCHAR2(30)  --
  --                               to hr_organization_information           --
  --                               org_information5%TYPE
  -- 1.4   14-Mar-2008   dduvvuri  Modified call to get_phf_si_rates (6828199) --
  ----------------------------------------------------------------------------
  FUNCTION  get_employer_info(p_assignment_id  IN NUMBER
                             ,p_info_type      IN VARCHAR2)
  RETURN VARCHAR2
  IS
  --

    l_proc_name          VARCHAR2(150);
    l_return_value       VARCHAR2(300);
    l_message            VARCHAR2(3000);
    l_ee_rate_type       VARCHAR2(30);
    l_er_rate_type       VARCHAR2(30);
    l_ee_rate            VARCHAR2(30);
    l_er_rate            VARCHAR2(30);
    /* Changes for bug 6828199 starts */
    l_ee_thrhld_rate     VARCHAR2(30);
    l_er_thrhld_rate     VARCHAR2(30);
    /* Changes for bug 6828199 end */
    l_ee_rounding_method VARCHAR2(30);
    l_er_rounding_method VARCHAR2(30);
    --
    -- Bug 3904374 Changes start. Modified the datatype from VARCHAR2(30) to hr_organization_information.org_information5%TYPE
    --
    l_phf_reg_num        hr_organization_information.org_information5%TYPE;
    l_pension_reg_num    hr_organization_information.org_information5%TYPE;
    l_injury_reg_num     hr_organization_information.org_information5%TYPE;
    l_maternity_reg_num  hr_organization_information.org_information5%TYPE;
    l_unemp_reg_num      hr_organization_information.org_information5%TYPE;
    l_medical_reg_num    hr_organization_information.org_information5%TYPE;
    l_ea_reg_num         hr_organization_information.org_information5%TYPE; -- Bug 3593118. Enterprise Annuity Employer Reg Num
    --
    -- Bug 3904374 Changes end
    --

    l_filing_date        DATE;

    l_phf_si_type        VARCHAR2(50);
    l_start_date         DATE;
    l_end_date           DATE;
    l_legal_employer_id  NUMBER;
    l_business_group_id  NUMBER;
    l_contribution_area  VARCHAR2(30);
    l_contribution_year  VARCHAR2(30);
    l_filling_date       DATE;
    l_report_type        VARCHAR2(3);
    l_hukuo_type         VARCHAR2(100); -- Bug 3886228. Hukuo type

    -- Cursor to fetch Legal Employer Name
    --
    CURSOR csr_legal_employer_name(p_legal_employer IN NUMBER)
    IS
      SELECT name
      FROM   hr_all_organization_units
      WHERE  organization_id = p_legal_employer;
    --

    -- Cursor to fetch Business Group Currency
    --
    CURSOR csr_org_currency(p_business_group_id IN NUMBER)
    IS
      SELECT hoi.org_information10
      FROM   hr_organization_information hoi
      WHERE  hoi.organization_id                                        = p_business_group_id
      AND    REPLACE(ltrim(rtrim(hoi.org_information_context)),' ','_') = 'Business_Group_Information';
    --

    -- Cursor to fetch Enterprise Organisation Category
    --
    CURSOR csr_ent_org_category(p_legal_employer_id IN NUMBER)
    IS
      SELECT hr_general.decode_lookup('CN_ENTRP_CATEGORY',hoi.org_information8)
      FROM   hr_organization_information hoi
      WHERE hoi.organization_id = p_legal_employer_id
      AND REPLACE(ltrim(rtrim(hoi.org_information_context)),' ','_') = 'PER_CORPORATE_INFO_CN';
    --

    -- Cursor to fetch Enterprise Organisation code
    --
    CURSOR csr_ent_org_code(p_legal_employer_id IN NUMBER)
    IS
      SELECT hoi.org_information7
      FROM   hr_organization_information hoi
      WHERE  hoi.organization_id = p_legal_employer_id
      AND REPLACE(ltrim(rtrim(hoi.org_information_context)),' ','_') = 'PER_CORPORATE_INFO_CN';
    --

    -- Cursor to fetch PHF/SI Registration number
    --
    CURSOR csr_phf_si_reg_num(p_legal_employer_id IN NUMBER)
    IS
      SELECT hoi.org_information5              -- PHF
            ,hoi.org_information6              -- Pension
            ,hoi.org_information15             -- Injury
            ,hoi.org_information17             -- Maternity
            ,hoi.org_information19             -- Unemployment
            ,hoi.org_information7              -- Medical
	    ,hoi.org_information3              -- Enterprise Annuity. (Bug 3593118)
      FROM   hr_organization_information hoi
      WHERE  hoi.organization_id                                        = p_legal_employer_id
      AND    REPLACE(ltrim(rtrim(hoi.org_information_context)),' ','_') = 'PER_EMPLOYER_INFO_CN';
    --

    --
    -- Bug 3886228 Changes start
    -- Cursor to fetch Hukuo Type
    --
    CURSOR csr_get_hukuo_type
    IS
      SELECT ppf.PER_INFORMATION4                -- Hukuo Type
      FROM   per_assignments_f paf
            ,per_people_f      ppf
      WHERE  paf.assignment_id = p_assignment_id
      AND    paf.person_id = ppf.person_id;
  --
  -- Bug 3886228 Changes end
  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.get_employer_info';
    l_return_value:= NULL;

    hr_utility.set_location('China : Entering -> '||l_proc_name, 10);
    hr_utility.set_location('China : Info Type-> '||p_info_type, 10);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- If info required is Filing Date
    --
    IF p_info_type = 'FILING_DATE' THEN
    --
      l_filing_date :=  NVL(l_filling_date,l_start_date);
      l_return_value := TO_CHAR(l_filing_date,'YYYY/MM/DD');
      hr_utility.set_location('China : Filling Date -> '||l_return_value, 20);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Insurance Type Code
    --
    IF p_info_type = 'INSURANCE_TYPE_CODE' THEN
    --
      l_return_value :=   l_phf_si_type;
      hr_utility.set_location('China : Insurance Type Code -> '||l_return_value, 30);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Insurance Type
    --
    IF p_info_type = 'INSURANCE_TYPE' THEN
    --
      l_return_value :=  hr_general.decode_lookup(p_lookup_type => 'CN_PHF_SI_CODE'
                                                 ,p_lookup_code => l_phf_si_type
                                                 );
      hr_utility.set_location('China : Insurance Type  -> '||l_return_value, 40);
      return l_return_value;
    --
    END IF;

    -- If info required is Employer Name
    --
    IF p_info_type = 'EMPLOYER_NAME' THEN
    --
      OPEN csr_legal_employer_name(l_legal_employer_id);
      FETCH csr_legal_employer_name
        INTO l_return_value;
      CLOSE csr_legal_employer_name;
      hr_utility.set_location('China : Employer Name -> '||l_return_value, 50);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Enterprise Organization Code
    --
    IF p_info_type = 'ENT_ORG_CODE' THEN
    --
      OPEN csr_ent_org_code(l_legal_employer_id);
      FETCH csr_ent_org_code
        INTO l_return_value;
      CLOSE csr_ent_org_code;
      hr_utility.set_location('China : Employer Name -> '||l_return_value, 60);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Enterprise Organization Category
    --
    IF p_info_type = 'ENT_ORG_CATEGORY' THEN
    --
      OPEN csr_ent_org_category(l_legal_employer_id);
      FETCH csr_ent_org_category
        INTO l_return_value;
      hr_utility.set_location('China : Enterprise Org Category -> '||l_return_value, 70);
      CLOSE csr_ent_org_category;
      RETURN l_return_value;
    --
    END IF;

    -- If info required is PHF SI Period
    --
    IF p_info_type = 'PHF_SI_PERIOD' THEN
    --
      -- Check if report type is EM
      IF l_report_type = 'EM' THEN
      --
        l_return_value := TO_CHAR(l_start_date,'YYYY/MM');
      --
      ELSE
      --
        l_return_value := TO_CHAR(l_start_date,'YYYY/MM/DD') ||'-'|| TO_CHAR(l_end_date,'YYYY/MM/DD');
      --
      END IF;
      hr_utility.set_location('China : Enterprise Org Category -> '||l_return_value, 80);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Currency
    --
    IF p_info_type = 'ORG_CURRENCY' THEN
    --
      OPEN csr_org_currency(l_business_group_id);
      FETCH csr_org_currency
        INTO l_return_value;
      CLOSE csr_org_currency;
      hr_utility.set_location('China : Org Currency -> '||l_return_value, 90);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Account Number
    --
    IF p_info_type = 'PHF_SI_ACC_NUM' THEN
    --
      OPEN csr_phf_si_reg_num(l_legal_employer_id);
      FETCH csr_phf_si_reg_num
        INTO  l_phf_reg_num
             ,l_pension_reg_num
             ,l_injury_reg_num
             ,l_maternity_reg_num
             ,l_unemp_reg_num
             ,l_medical_reg_num
	     ,l_ea_reg_num;       -- Enterprise Annuity. Bug 3593118
      CLOSE csr_phf_si_reg_num;

      IF l_phf_si_type = 'PHF' THEN
      --
        l_return_value := l_phf_reg_num;
      --
      ELSIF l_phf_si_type = 'PENSION' THEN
      --
        l_return_value := l_pension_reg_num;
      --
      ELSIF l_phf_si_type = 'INJURY' THEN
      --
        l_return_value := l_injury_reg_num;
      --
      ELSIF l_phf_si_type = 'MATERNITY' THEN
      --
        l_return_value := l_maternity_reg_num;
      --
      ELSIF l_phf_si_type = 'UNEMPLOYMENT' THEN
      --
        l_return_value := l_unemp_reg_num;
      --
      ELSIF l_phf_si_type IN ('MEDICAL','SUPPMED') THEN
      --
        l_return_value := l_medical_reg_num;
      --
      ELSIF l_phf_si_type = 'ENTANN' THEN
      --
      --Enterprise Annuity. Bug 3593118
      --
        l_return_value := l_ea_reg_num;
      --
      END IF;

      --
      hr_utility.set_location('China : PHF/SI Reg Num -> '||l_return_value, 100);
      RETURN l_return_value;
    --
    END IF;

    -- If info required is Filing Date
    --
    IF p_info_type = 'ER_CONT_PERCENT' THEN
    --
    -- Bug 3886228 Changes start
    --
       OPEN csr_get_hukuo_type;
       FETCH csr_get_hukuo_type INTO l_hukuo_type;
       IF csr_get_hukuo_type%NOTFOUND THEN
          l_hukuo_type:=NULL;
          CLOSE csr_get_hukuo_type;
       END IF;
       CLOSE csr_get_hukuo_type;
    --
    -- Bug 3886228 Changes end
    --
    -- Bug 3593118
    -- Enterprise Annuity - Added new parameter p_assignment_id in call to
    -- get_phf_si_rates
    --
      l_message := pay_cn_deductions.get_phf_si_rates
                               (p_assignment_id     => NULL
			       ,p_business_group_id => l_business_group_id
                               ,p_contribution_area => l_contribution_area
                               ,p_phf_si_type       => l_phf_si_type
                               ,p_employer_id       => l_legal_employer_id
                               ,p_hukou_type        => l_hukuo_type         -- Bug 3886228 Changed NULL to l_hukuo_type
                               ,p_effective_date    => l_start_date
                               --
                               ,p_ee_rate_type      => l_ee_rate_type
                               ,p_er_rate_type      => l_er_rate_type
                               ,p_ee_rate           => l_ee_rate
                               ,p_er_rate           => l_er_rate
			       ,p_ee_thrhld_rate    => l_ee_thrhld_rate  /* For bug 6828199 */
			       ,p_er_thrhld_rate    => l_er_thrhld_rate  /* For bug 6828199 */
                               ,p_ee_rounding_method   => l_ee_rounding_method
                               ,p_er_rounding_method   => l_er_rounding_method
                               );

      IF l_message = 'SUCCESS' THEN
      --
        IF l_er_rate_type = 'PERCENTAGE' THEN
        --
          l_return_value := l_er_rate;
          hr_utility.set_location('China : ER Cont Percent -> '||l_return_value, 110);
          RETURN l_return_value;
        --
        END IF;
      --
      ELSE
      --
        RETURN l_return_value;
      --
      END IF;
    --
    END IF;

    -- No Info Type Matches
    --
    hr_utility.set_location('China :  Leaving -> '|| l_proc_name , 120);
    RETURN l_return_value;
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_legal_employer_name%ISOPEN THEN
      --
        CLOSE csr_legal_employer_name;
      --
      END IF;

      IF csr_org_currency%ISOPEN THEN
      --
         CLOSE csr_org_currency;
      --
      END IF;
      IF csr_ent_org_category%ISOPEN THEN
      --
        CLOSE csr_ent_org_category;
      --
      END IF;

      IF csr_ent_org_code%ISOPEN THEN
      --
         CLOSE csr_ent_org_code;
      --
      END IF;

      IF csr_phf_si_reg_num%ISOPEN THEN
      --
         CLOSE csr_phf_si_reg_num;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 180);
      RAISE;
  --
  END get_employer_info;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_EMPLOYEE_INFO                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to get Employee Details based on Info Type   --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_date_earned        DATE                             --
  --                  p_info_type          VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   06-Jul-2004   sshankar  Added new parameter p_assignment_id in   --
  --                               call to get_phf_si_rates (Bug 3593118)   --
  --                               to support Enterprise Annuity            --
  -- 1.2   15-Sep-2004   snekkala  Added code to get phf/si rates based on  --
  --                               Hukuo Type                               --
  -- 1.3   14-Mar-2008   dduvvuri  Modified call to get_phf_si_rates (bug 6828199)
  ----------------------------------------------------------------------------
  FUNCTION  get_employee_info(p_assignment_id  IN NUMBER
                             ,p_date_earned    IN DATE
                             ,p_info_type      IN VARCHAR2)
  RETURN VARCHAR2
  IS
  --
    l_return_value    VARCHAR2(300);
    l_proc_name       VARCHAR2(150);

    l_ee_rate_type    VARCHAR2(30);
    l_er_rate_type    VARCHAR2(30);
    l_ee_rate         VARCHAR2(30);
    l_er_rate         VARCHAR2(30);
    /* Changes for bug 6828199 start */
    l_ee_thrhld_rate  VARCHAR2(30);
    l_er_thrhld_rate  VARCHAR2(30);
    /* Changes for bug 6828199 end */
    l_ee_rounding_method VARCHAR2(30);
    l_er_rounding_method VARCHAR2(30);
    l_message         VARCHAR2(2000);
    l_work_life_date  VARCHAR2(50);

    l_phf_si_type        VARCHAR2(50);
    l_start_date         DATE;
    l_end_date           DATE;
    l_legal_employer_id  NUMBER;
    l_business_group_id  NUMBER;
    l_contribution_area  VARCHAR2(30);
    l_contribution_year  VARCHAR2(30);
    l_filling_date       DATE;
    l_report_type        VARCHAR2(3);
    l_hukuo_type         VARCHAR2(100);  -- Bug 3886228. Hukuo Type

    -- Cursor to fetch Ethnic Group
    --
    CURSOR csr_ethnic_group
    IS
    --
      SELECT hr_general.decode_lookup('CN_RACE',pap.per_information17)
      FROM   per_all_assignments_f    paa
            ,per_all_people_f         pap
      WHERE  paa.assignment_id = p_assignment_id
      AND    pap.person_id     = paa.person_id
      AND    p_date_earned     BETWEEN paa.effective_start_date
                               AND     paa.effective_end_date
      AND    p_date_earned     BETWEEN pap.effective_start_date
                               AND     pap.effective_end_date;
    --

    -- Cursor to fetch Hukou Type
    --
    /*3592894, Removed table per_people_extra_info*/
    CURSOR csr_hukou_type
    IS
    --
      SELECT hr_general.decode_lookup('CN_HUKOU_TYPE',pap.per_information4 )
      FROM   per_all_assignments_f    paa
            ,per_all_people_f         pap
      WHERE  paa.assignment_id     = p_assignment_id
      AND    pap.person_id         = paa.person_id
      AND    p_date_earned         BETWEEN paa.effective_start_date
                                   AND     paa.effective_end_date
      AND    p_date_earned         BETWEEN pap.effective_start_date
                                   AND     pap.effective_end_date;
    --

    -- Cursor to fetch Work Life Start Date
    --
    CURSOR csr_work_life_start_date
    IS
    --
      SELECT ppei.pei_information2    Work_Life_Start_Date
      FROM   per_all_assignments_f    paa
            ,per_all_people_f         pap
            ,per_people_extra_info    ppei
      WHERE  paa.assignment_id     = p_assignment_id
      AND    pap.person_id         = paa.person_id
      AND    ppei.person_id        = pap.person_id (+)
      AND    ppei.information_type = 'PER_OTH_EMP_DATA_CN'
      AND    p_date_earned     BETWEEN paa.effective_start_date
                               AND     paa.effective_end_date
      AND    p_date_earned     BETWEEN pap.effective_start_date
                               AND     pap.effective_end_date;
    --

    -- Cursor to fetch Job Category
    --
    CURSOR csr_job_category
    IS
    --
      SELECT hr_general.decode_lookup('JOB_CATEGORIES', pjei.jei_information1)
      FROM   per_all_assignments_f    paa
            ,per_job_extra_info       pjei
      WHERE  paa.assignment_id        = p_assignment_id
      AND    pjei.job_id              = paa.job_id
      AND    information_type         = 'Job Category'
      AND    jei_information_category = 'Job Category'
      AND    p_date_earned            BETWEEN paa.effective_start_date
                                      AND     paa.effective_end_date;
    --
    --
    -- Bug 3886228 Changes start
    -- Cursor to fetch Hukuo Type
    --
    CURSOR csr_get_hukuo_type
    IS
      SELECT ppf.PER_INFORMATION4                -- Hukuo Type
      FROM   per_assignments_f paf
            ,per_people_f      ppf
      WHERE  paf.assignment_id = p_assignment_id
      AND    paf.person_id = ppf.person_id;
  --
  -- Bug 3886228 Changes end
  --
  BEGIN
  --
    l_proc_name     := 'pay_cn_ext.get_employee_info';
    l_return_value  := NULL;

    hr_utility.set_location('China : Entering      -> '||l_proc_name, 10);
    hr_utility.set_location('China : Assignment ID -> '||p_assignment_id, 10);
    hr_utility.set_location('China : Date Earned   -> '||p_date_earned, 10);
    hr_utility.set_location('China : Info Type     -> '||p_info_type, 10);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- If info Type required is Contribution Percent
    --
    IF p_info_type = 'EE_CONT_PERCENT' THEN
    --
    -- Bug 3886228 Changes start
    --
       OPEN csr_get_hukuo_type;
       FETCH csr_get_hukuo_type INTO l_hukuo_type;
       IF csr_get_hukuo_type%NOTFOUND THEN
          l_hukuo_type:=NULL;
          CLOSE csr_get_hukuo_type;
       END IF;
       CLOSE csr_get_hukuo_type;
    --
    -- Bug 3886228 Changes end
    --
    -- Bug 3593118
    -- Enterprise Annuity - Added new parameter p_assignment_id in call to
    -- get_phf_si_rates
    --
      l_message := pay_cn_deductions.get_phf_si_rates
                               (p_assignment_id     => p_assignment_id
			       ,p_business_group_id => l_business_group_id
                               ,p_contribution_area => l_contribution_area
                               ,p_phf_si_type       => l_phf_si_type
                               ,p_employer_id       => l_legal_employer_id
                               ,p_hukou_type        => l_hukuo_type  -- Bug 3886228 Changed NULL to l_hukuo_type
                               ,p_effective_date    => l_start_date
                                --
                               ,p_ee_rate_type      => l_ee_rate_type
                               ,p_er_rate_type      => l_er_rate_type
                               ,p_ee_rate           => l_ee_rate
                               ,p_er_rate           => l_er_rate
			       ,p_ee_thrhld_rate    => l_ee_thrhld_rate /* For bug 6828199 */
			       ,p_er_thrhld_rate    => l_er_thrhld_rate /* For bug 6828199 */
                               ,p_ee_rounding_method   => l_ee_rounding_method
                               ,p_er_rounding_method   => l_er_rounding_method
                               );

      IF l_message = 'SUCCESS' THEN
      --
        IF l_ee_rate_type = 'PERCENTAGE' THEN
        --
          l_return_value := l_ee_rate;
          hr_utility.set_location('China : Employee Cont Percent -> '||l_return_value, 20);
          RETURN l_return_value;
        --
        END IF;
      --
      ELSE
      --
        RETURN l_return_value;
      --
      END IF;
    --
    END IF;

    -- If info Type required is Ethnic Group
    --
    IF p_info_type = 'ETHNIC_GROUP' THEN
    --
      OPEN csr_ethnic_group;
      FETCH csr_ethnic_group
        INTO l_return_value;
      CLOSE csr_ethnic_group;
      hr_utility.set_location('China : Ethnic Group -> '||l_return_value, 30);
      RETURN l_return_value;
    --
    END IF;

    -- If info Type required is Hukou Type
    --
    IF p_info_type = 'HUKOU_TYPE' THEN
    --
      OPEN csr_hukou_type;
      FETCH csr_hukou_type
        INTO l_return_value;
      CLOSE csr_hukou_type;
      hr_utility.set_location('China : Hukou Type -> '||l_return_value, 40);
      RETURN l_return_value;
    --
    END IF;

    -- If info Type required is Work Life Start Date
    --
    IF p_info_type = 'WORK_LIFE_START_DATE' THEN
    --
      OPEN csr_work_life_start_date;
      FETCH csr_work_life_start_date
        INTO l_work_life_date;
      IF csr_work_life_start_date%NOTFOUND THEN
      --
        CLOSE csr_work_life_start_date;
	RETURN l_return_value;
      --
      END IF;
      CLOSE csr_work_life_start_date;
      l_return_value := TO_CHAR(TO_DATE(l_work_life_date,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD');
      hr_utility.set_location('China : Work Life Start Date -> '||l_return_value, 50);
      RETURN l_return_value;
    --
    END IF;

    -- If info Type required is Job Category
    --
    IF p_info_type = 'JOB_CATEGORY' THEN
    --
      OPEN csr_job_category;
      FETCH csr_job_category
        INTO l_return_value;
      IF csr_job_category%NOTFOUND THEN
      --
        CLOSE csr_job_category;
	RETURN l_return_value;
      --
      END IF;
      CLOSE csr_job_category;
      hr_utility.set_location('China : Job Category -> '||l_return_value, 50);
      RETURN l_return_value;
    --
    END IF;
    --

    -- No Info Type Matches
    --

    hr_utility.set_location('China  Leaving -> '|| l_proc_name , 60);
    RETURN l_return_value;
  --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_ethnic_group%ISOPEN THEN
      --
        CLOSE csr_ethnic_group;
      --
      END IF;

      IF csr_hukou_type%ISOPEN THEN
      --
         CLOSE csr_hukou_type;
      --
      END IF;
      IF csr_work_life_start_date%ISOPEN THEN
      --
        CLOSE csr_work_life_start_date;
      --
      END IF;

      IF csr_job_category%ISOPEN THEN
      --
         CLOSE csr_job_category;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 80);
      RAISE;
  --
  END get_employee_info;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_BALANCE_VALUE                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to set the Balance value of a given Balance  --
  --                  and Balance Dimension                                 --
  --                  This function returns                                 --
  --                  o Previous month value if Info Type is PREV_MONTH     --
  --                  o Current month value if Info Type is CURR_MONTH      --
  --                  o Prev Years average value of the defined balance     --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_balance_name       VARCHAR2                         --
  --                  p_balance_dimension  VARCHAR2                         --
  --                  p_info_type          VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   03-Feb-2004   saikrish  Simplified code(Bug# 3411273)            --
  -- 1.2   01-Mar-2004   sshankar  Modified Return l_bal_value to           --
  --                               Return round(l_bal_valu2,2). Bug 3475437 --
  -- 1.3   31-May-2004   snekkala  Changed cursor csr_assg_act(Bug# 3603564)--
  ----------------------------------------------------------------------------
  FUNCTION  get_balance_value( p_assignment_id       IN NUMBER
                             , p_business_group_id   IN NUMBER
                             , p_balance_name        IN VARCHAR2
                             , p_balance_dimension   IN VARCHAR2
                             , p_info_type           IN VARCHAR2
			     )
  RETURN NUMBER
  IS
  --

    l_bal_value              NUMBER;
    l_proc_name              VARCHAR2(150);
    l_date_earned            DATE;
    l_prev_month             DATE;
    l_no_of_runs             NUMBER;
    l_defined_balance_id     pay_defined_balances.defined_balance_id%TYPE;
    l_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;

    l_phf_si_type        VARCHAR2(50);
    l_start_date         DATE;
    l_end_date           DATE;
    l_legal_employer_id  NUMBER;
    l_business_group_id  NUMBER;
    l_contribution_area  VARCHAR2(30);
    l_contribution_year  VARCHAR2(30);
    l_filling_date       DATE;
    l_report_type        VARCHAR2(3);

    l_mod_start_date     DATE;
    l_mod_end_date       DATE;

    -- Cursor to fetch defined Balance ID
    --
    CURSOR csr_defined_balance (p_balance_name IN VARCHAR2, p_balance_dimension IN VARCHAR2)
    IS
    --
      SELECT defined.defined_balance_id
      FROM   pay_balance_types bal
           , pay_balance_dimensions dim
           , pay_defined_balances defined
      WHERE  bal.legislation_code = 'CN'
      AND    bal.balance_name = p_balance_name
      AND    dim.legislation_code = 'CN'
      AND    dim.dimension_name = p_balance_dimension
      AND    bal.balance_type_id  = defined.balance_type_id
      AND    dim.balance_dimension_id = defined.balance_dimension_id;
    --

    --
    -- Bug 3603564 changes start
    --
    -- Cursor to fetch Assignment Action ID
    --
    CURSOR csr_assg_act(p_start_date IN DATE
                       ,p_end_date   IN DATE)
    IS
    --
      SELECT max(paa.assignment_action_id)
      FROM   pay_assignment_actions paa
           , pay_payroll_actions    ppa
           , per_all_assignments_f  paf
      WHERE  paa.payroll_action_id = ppa.payroll_action_id
      AND    paf.assignment_id     = p_assignment_id
      AND    paf.assignment_id     = paa.assignment_id
      AND    paa.action_status     = 'C'
      AND    ppa.action_status     = 'C'
      AND    ppa.action_type       IN ('R','Q')
      AND    ppa.effective_date    BETWEEN p_start_date
                                   AND     p_end_date
      AND    ppa.effective_date    BETWEEN paf.effective_start_date
                                   AND     paf.effective_end_date
      AND    ppa.business_group_id = p_business_group_id;

    --
    -- Bug 3603564 changes end
    --
    -- Cursor to fetch Date Earned of the given assignment action id
    --
    CURSOR csr_date_earned(p_assg_act_id IN NUMBER)
    IS
    --
      SELECT ppa.date_earned
      FROM   pay_assignment_actions paa
           , pay_payroll_actions    ppa
      WHERE  paa.assignment_action_id     = p_assg_act_id
      AND    paa.payroll_action_id        = ppa.payroll_action_id;

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.get_balance_value';
    l_bal_value   :=0;

    hr_utility.set_location('China    Entering              -> '    || l_proc_name         , 10);
    hr_utility.set_location('China    p_assignment_id       -> '    || p_assignment_id     , 10);
    hr_utility.set_location('China    p_business_group_id   -> '    || p_business_group_id , 10);
    hr_utility.set_location('China    p_balance_name        -> '    || p_balance_name      , 10);
    hr_utility.set_location('China    p_balance_dimension   -> '    || p_balance_dimension , 10);
    hr_utility.set_location('China    p_info_type           -> '    || p_info_type         , 10);

    -- Get Globals
    --
    get_globals ( p_phf_si_type             =>    l_phf_si_type
                , p_start_date              =>    l_start_date
                , p_end_date                =>    l_end_date
                , p_legal_employer_id       =>    l_legal_employer_id
                , p_business_group_id       =>    l_business_group_id
                , p_contribution_area       =>    l_contribution_area
                , p_contribution_year       =>    l_contribution_year
                , p_filling_date            =>    l_filling_date
                , p_report_type             =>    l_report_type
                );

    -- Fetch the Defined balance id
    --
    OPEN csr_defined_balance(p_balance_name,p_balance_dimension);
    FETCH csr_defined_balance
      INTO l_defined_balance_id;
    IF csr_defined_balance%NOTFOUND THEN
    --
      hr_utility.set_location('China : Defined Balance not found', 20);
      CLOSE csr_defined_balance;
      RETURN l_bal_value;
    --
    END IF;
    CLOSE csr_defined_balance;

    hr_utility.set_location('China    l_defined_balance_id     -> '    || l_defined_balance_id   , 30);

    IF p_info_type = 'PREV_MONTH' THEN
       l_mod_start_date := TRUNC(TRUNC(l_start_date,'MM')-1,'MM');
       l_mod_end_date   := LAST_DAY(l_mod_start_date);

    ELSIF p_info_type = 'CURR_MONTH' THEN
       l_mod_start_date := l_start_date;
       l_mod_end_date   := LAST_DAY(l_mod_start_date);

    END IF;

    OPEN csr_assg_act(l_mod_start_date,l_mod_end_date);
    FETCH csr_assg_act INTO l_assignment_action_id;

    IF csr_assg_act%FOUND THEN
      hr_utility.set_location('China : Assignment action id -> ' || l_assignment_action_id, 50);

      OPEN csr_date_earned(l_assignment_action_id);
      FETCH csr_date_earned INTO l_date_earned;
      CLOSE csr_date_earned;

      hr_utility.set_location('China : Date Earned ->' || l_date_earned, 60);

      -- Set context
      pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_date_earned));

      -- Get the value
      l_bal_value := pay_balance_pkg.get_value ( p_defined_balance_id     => l_defined_balance_id
                                               , p_assignment_action_id   => l_assignment_action_id);

    ELSE
      hr_utility.set_location('China : Assignment action id -> ' || l_assignment_action_id, 55);
    END IF;

    CLOSE csr_assg_act;



    -- If the Info Type is Previous Year
    --
    IF p_info_type = 'PREV_YEAR' THEN
    --
      hr_utility.set_location('China : Fetch Assignment action id ', 100);

      -- Fetch Assignment Action ID of previous month
      --
      l_prev_month := TRUNC(TRUNC(l_start_date,'MM')-1,'MM');
      OPEN csr_assg_act(l_prev_month
                       ,LAST_DAY(l_prev_month));
      FETCH csr_assg_act
        INTO l_assignment_action_id;

      IF csr_assg_act%FOUND THEN
      --
        hr_utility.set_location('China : Assignment action id -> ' || l_assignment_action_id, 110);

        -- Get Date Earned context
        --
        OPEN csr_date_earned(l_assignment_action_id);
        FETCH csr_date_earned
          INTO l_date_earned;
        CLOSE csr_date_earned;

        hr_utility.set_location('China : Date Earned ->', 60);

        -- Set context
        pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_date_earned));

        -- Get the value
        l_bal_value := pay_balance_pkg.get_value ( p_defined_balance_id     => l_defined_balance_id
                                                 , p_assignment_action_id   => l_assignment_action_id);

        -- Set Assignment ID Context
        pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);

        -- Fetch Number of runs in Previous Year
        --
        l_no_of_runs := pay_balance_pkg.run_db_item('CN_PAYROLL_RUN_MONTHS_PREV_YEAR',p_business_group_id,'CN');
        hr_utility.set_location('China : Balance Prev Year ->' || l_bal_value, 120);
        hr_utility.set_location('China : Number of runs    ->' || l_no_of_runs, 120);
        l_bal_value  := l_bal_value/l_no_of_runs;
      --
      ELSE
      --
        hr_utility.set_location('China : Assignment action id not Found', 110);
      --
      END IF;
      CLOSE csr_assg_act;
    --
    END IF;

    hr_utility.set_location('China    l_bal_value     -> '    || l_bal_value   , 130);
    hr_utility.set_location('China    Leaving -> '|| l_proc_name , 130);

    --
    -- Bug 3475437
    -- Modified Return l_bal_value to Return round(l_bal_valu2,2)
    -- to restrict balance value to be displayed upto 2 decimal places only.
    --
    RETURN round(l_bal_value,2);

  EXCEPTION
    WHEN OTHERS THEN
      IF csr_defined_balance%ISOPEN THEN
        CLOSE csr_defined_balance;
      END IF;
      IF csr_assg_act%ISOPEN THEN
         CLOSE csr_assg_act;
      END IF;
      IF csr_date_earned%ISOPEN THEN
        CLOSE csr_date_earned;
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 140);
      RAISE;

  END get_balance_value;


  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_ELEMENT_ENTRY                                     --
  -- Type           : FUNCTION                                              --
  -- Access         : Public                                                --
  -- Description    : Function to check whether an assignment has element   --
  --                  entries for the given PHF/SI Type                     --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id      NUMBER                           --
  --                  p_business_group_id  NUMBER                           --
  --                  p_effective_date     DATE                             --
  --                  p_phf_si_type        VARCHAR2                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   10-Jan-2004   bramajey  Created this function                    --
  -- 1.1   03-Feb-2004   saikrish  Added p_start_date,p_end_date,           --
  --                               p_phf_si_type (Bug# 3411273)             --
  ----------------------------------------------------------------------------
  FUNCTION  get_element_entry ( p_assignment_id       IN NUMBER
                              , p_business_group_id   IN NUMBER
			      , p_effective_date      IN DATE
			      , p_phf_si_type         IN VARCHAR2
                              )
  RETURN VARCHAR2
  IS
  --

    l_return_value  CHAR(1);
    l_count         NUMBER;
    l_element_name  pay_element_types_f.element_name%TYPE;
    l_proc_name     VARCHAR2(150);

    -- Cursor to fetch count of element entry
    -- Bug 3415164
    -- Using p_effective_date instead of p_start_date
    CURSOR csr_element_entry(p_end_date     IN DATE
                            ,p_element_name IN VARCHAR2)
    IS
    --
      SELECT COUNT(*)
      FROM   pay_element_entries_f pee
            ,pay_element_links_f   pel
            ,pay_element_types_f   pet
            ,per_all_assignments_f paa
      WHERE  paa.assignment_id     = p_assignment_id
      AND    paa.business_group_id = p_business_group_id
      AND    p_effective_date      BETWEEN paa.effective_start_date
                                   AND     paa.effective_end_date
      AND    pee.assignment_id     = paa.assignment_id
      AND    p_effective_date      BETWEEN pee.effective_start_date
                                   AND     pee.effective_end_date
      AND    pee.element_link_id   = pel.element_link_id
      AND    p_effective_date      BETWEEN pel.effective_start_date
                                   AND     pel.effective_end_date
      AND    pel.element_type_id   = pet.element_type_id
      AND    pet.element_name      = p_element_name
      AND    p_effective_date      BETWEEN pet.effective_start_date
                                   AND     pet.effective_end_date;

  --
  BEGIN
  --
    l_proc_name     := 'pay_cn_ext.get_element_entry';
    l_return_value  := 'N';

    hr_utility.set_location('China : Entering              -> ' || l_proc_name , 10);
    hr_utility.set_location('China : p_assignment_id       -> ' || p_assignment_id     , 10);
    hr_utility.set_location('China : p_business_group_id   -> ' || p_business_group_id , 10);
    hr_utility.set_location('China : p_effective_date      -> ' || p_effective_date    , 10);
    hr_utility.set_location('China : p_phf_si_type         -> ' || p_phf_si_type       , 10);


    -- Get Element Name
    l_element_name := get_element_name(p_phf_si_type);

    hr_utility.set_location('China l_element_name -> '|| l_element_name , 20);

    -- Fetch the count of entries
    -- Bug 3415164
    -- Passing only p_end_date and element_name
    --
    OPEN csr_element_entry(p_effective_date,l_element_name);
    FETCH csr_element_entry INTO l_count;
    CLOSE csr_element_entry;

    -- If the count is greater than 0 then the assignment has element entries
    -- for that PHF/SI Type
    --
    IF l_count > 0 THEN
    --
      l_return_value := 'Y';
    --
    ELSE
    --
      -- IF not return N
      l_return_value := 'N';
    --
    END IF;

    hr_utility.set_location('China l_return_value -> '|| l_return_value , 30);
    hr_utility.set_location('China Leaving  -> '|| l_proc_name , 40);

    RETURN l_return_value;
 --
  EXCEPTION
  --
    WHEN OTHERS THEN
      IF csr_element_entry%ISOPEN THEN
      --
        CLOSE csr_element_entry;
      --
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 50);
      RAISE;
  --
  END get_element_entry;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_OVERRIDE_SIC_CODE                                 --
  -- Type           : FUNCTION                                              --
  -- Access         : Privatre                                              --
  -- Description    : Function to check whether an assignment has Override  --
  --                  SIC code for the given PHF/SI Type                    --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_element_name      IN VARCHAR2                       --
  --                  p_assignment_id     IN NUMBER                         --
  --     	      p_date_earned       IN DATE                           --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   03-Feb-2004   saikrish  Created this function(Bug# 3411840)      --
  -- 1.1   04-Feb-2004   saikrish  Corrected return value                   --
  -- 1.2   05-Feb-2004   saikrish  Removed p_business_group_id, cursor modified
  ----------------------------------------------------------------------------
  FUNCTION  get_override_sic_code ( p_element_name      IN VARCHAR2
				  , p_assignment_id     IN NUMBER
				  , p_date_earned       IN DATE
				  )
  RETURN VARCHAR2
  IS
  --

    l_return_value  VARCHAR2(5);
    l_proc_name     VARCHAR2(150);

    CURSOR csr_override_sic_code ( p_element_name IN VARCHAR2
                                 , p_assignment_id IN NUMBER
				 , p_date_earned IN   DATE
				 ) IS
   SELECT target.ENTRY_INFORMATION1
   FROM   per_all_assignments_f assign
         ,pay_element_entries_f target
         ,pay_element_links_f  link
         ,pay_element_types_f  type
   WHERE  assign.assignment_id  = p_assignment_id
   AND    target.assignment_id  = assign.assignment_id
   AND    target.entry_information_category = 'CN_PHF AND SI INFORMATION'
   AND    target.element_link_id = link.element_link_id
   AND    link.element_type_id  = type.element_type_id
   AND    type.element_name     = p_element_name
   AND    p_date_earned BETWEEN assign.effective_start_date
                    AND assign.effective_end_date
   AND    p_date_earned BETWEEN target.effective_start_date
                    AND target.effective_end_date
   AND    p_date_earned BETWEEN link.effective_start_date
                    AND link.effective_end_date
   AND    p_date_earned BETWEEN type.effective_start_date
                    AND type.effective_end_date;


    l_entry_information1   pay_element_entries_f.entry_information1%TYPE;

  --
  BEGIN
  --
    l_proc_name   := 'pay_cn_ext.get_override_sic_code';

    hr_utility.set_location('China : Entering              -> ' || l_proc_name , 10);
    hr_utility.set_location('China : p_element_name        -> ' || p_element_name     , 10);
    hr_utility.set_location('China : p_assignment_id       -> ' || p_assignment_id     , 10);
    hr_utility.set_location('China : p_date_earned         -> ' || p_date_earned , 10);

    -- Fetch the Override SIC Code
    OPEN csr_override_sic_code( p_element_name
                              , p_assignment_id
			      , p_date_earned
			      );
    FETCH csr_override_sic_code INTO l_entry_information1;
    IF csr_override_sic_code%FOUND AND l_entry_information1 IS NOT NULL THEN
       l_return_value := l_entry_information1;
    ELSE
       l_return_value := NULL;
    END IF;

    CLOSE csr_override_sic_code;

    hr_utility.set_location('China : l_return_value -> '|| NVL(l_return_value,'NULL') , 30);
    hr_utility.set_location('China : Leaving  -> '|| l_proc_name , 40);

    RETURN l_return_value;

  EXCEPTION
      WHEN OTHERS THEN
      IF csr_override_sic_code%ISOPEN THEN
         CLOSE csr_override_sic_code;
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 50);
      RAISE;

  END get_override_sic_code;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : GET_ASSIGNMENT_ACTION                                 --
  -- Type           : FUNCTION                                              --
  -- Access         : Private                                               --
  -- Description    : Function to check whether an assignment has assignment--
  --                  action id for the given period                        --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_assignment_id       IN NUMBER                       --
  --                  p_business_group_id   IN NUMBER                       --
  --		      p_start_date          IN DATE                         --
  --		      p_end_date            IN DATE                         --
  -- Change History :                                                       --
  ----------------------------------------------------------------------------
  -- Rev#  Date          Userid    Description                              --
  ----------------------------------------------------------------------------
  -- 1.0   03-Feb-2004   saikrish  Created this function(Bug# 3411273)      --
  -- 1.1   31-May-2004   snekkala  Changed cursor csr_assg_act(Bug# 3603564)--
  ----------------------------------------------------------------------------
  FUNCTION  get_assignment_action ( p_assignment_id       IN NUMBER
                                  , p_business_group_id   IN NUMBER
				  , p_start_date          IN DATE
				  , p_end_date            IN DATE
                                  )
  RETURN VARCHAR2
  IS
  --

    l_return_value  CHAR(1);
    l_proc_name     VARCHAR2(150);

    --
    -- Bug 3603564 changes start
    --
    CURSOR csr_assg_act(p_start_date IN DATE
                        ,p_end_date   IN DATE)
    IS
      SELECT max(paa.assignment_action_id)
      FROM   pay_assignment_actions paa
           , pay_payroll_actions    ppa
           , per_all_assignments_f  paf
      WHERE  paa.payroll_action_id = ppa.payroll_action_id
      AND    paf.assignment_id     = p_assignment_id
      AND    paf.assignment_id     = paa.assignment_id
      AND    paa.action_status     = 'C'
      AND    ppa.action_status     = 'C'
      AND    ppa.action_type       IN ('R','Q')
      AND    ppa.effective_date    BETWEEN p_start_date
                                   AND     p_end_date
      AND    ppa.effective_date    BETWEEN paf.effective_start_date
                                   AND     paf.effective_end_date
      AND    ppa.business_group_id = p_business_group_id;
      --
      -- Bug 3603564 changes end
      --
      l_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;

  BEGIN

    l_proc_name     := 'pay_cn_ext.get_assignment_action';
    l_return_value  := 'N';

    hr_utility.set_location('China : Entering              -> ' || l_proc_name , 10);
    hr_utility.set_location('China : p_assignment_id       -> ' || p_assignment_id     , 10);
    hr_utility.set_location('China : p_business_group_id   -> ' || p_business_group_id , 10);

    -- Fetch the assignment action
    OPEN csr_assg_act(p_start_date,p_end_date);
    FETCH csr_assg_act INTO l_assignment_action_id;
    CLOSE csr_assg_act;

    hr_utility.set_location('China : l_assignment_action_id   -> ' || l_assignment_action_id , 20);

    --In case the assignment actions don't exist, return N
    IF NVL(l_assignment_action_id,0) = 0 THEN
        l_return_value := 'N';
    ELSE
        l_return_value := 'Y';
    END IF;

    hr_utility.set_location('China l_return_value -> '|| l_return_value , 30);
    hr_utility.set_location('China Leaving  -> '|| l_proc_name , 40);

    RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      IF csr_assg_act%ISOPEN THEN
         CLOSE csr_assg_act;
      END IF;

      hr_utility.set_location('China : Exception, Leaving: '||l_proc_name, 50);
      RAISE;

  END get_assignment_action;


--
END pay_cn_ext;

/
