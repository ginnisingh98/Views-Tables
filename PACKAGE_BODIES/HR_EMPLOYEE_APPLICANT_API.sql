--------------------------------------------------------
--  DDL for Package Body HR_EMPLOYEE_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EMPLOYEE_APPLICANT_API" 
/* $Header: peemaapi.pkb 120.15.12010000.10 2010/05/27 07:53:37 gpurohit ship $ */
AS
  --
  -- Package variables
  --
  g_package                      VARCHAR2(33) := 'hr_employee_applicant_api.';
  --
  -- #2264569
   g_retain_apl varchar2(1)    := 'R'; -- indicates Retain asg
   g_convert_apl varchar2(1)   := 'C'; --           Convert asg
   g_end_date_apl varchar2(1)  := 'E'; --           End Date asg

  --
  -- Package cursors
  --
  CURSOR csr_future_asgs
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    ,p_assignment_id                IN     per_all_assignments_f.assignment_id%type --2264191 added
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
      FROM per_assignments_f asg
     WHERE asg.person_id             = csr_future_asgs.p_person_id
       AND asg.effective_start_date >  csr_future_asgs.p_effective_date
       AND (p_assignment_id is null OR
            (p_assignment_id is not null AND
             p_assignment_id = asg.assignment_id));
  --
  CURSOR csr_nonaccepted_asgs
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
      FROM per_assignments_f asg
          ,per_assignment_status_types ast
     WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
       AND asg.person_id                 = csr_nonaccepted_asgs.p_person_id
       AND csr_nonaccepted_asgs.p_effective_date BETWEEN asg.effective_start_date
                                                     AND asg.effective_end_date
       AND asg.assignment_type           = 'A'
       AND ast.per_system_status        <> 'ACCEPTED';
  --
  CURSOR csr_accepted_asgs
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE DEFAULT hr_api.g_number
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
          ,asg.vacancy_id
      FROM per_assignments_f asg
          ,per_assignment_status_types ast
     WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
       AND asg.person_id                 = csr_accepted_asgs.p_person_id
       AND (  asg.assignment_id                 = csr_accepted_asgs.p_assignment_id
           OR csr_accepted_asgs.p_assignment_id = hr_api.g_number)
       AND csr_accepted_asgs.p_effective_date BETWEEN asg.effective_start_date
                                                  AND asg.effective_end_date
       AND asg.assignment_type           = 'A'
       AND ast.per_system_status         = 'ACCEPTED';
  --
  CURSOR csr_primary_asgs
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
      FROM per_assignments_f asg
          ,per_assignment_status_types ast
     WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
       AND asg.person_id                 = csr_primary_asgs.p_person_id
       AND csr_primary_asgs.p_effective_date BETWEEN asg.effective_start_date
                                                 AND asg.effective_end_date
       AND asg.assignment_type           = 'E'
       AND asg.primary_flag              = 'Y'
       AND ast.per_system_status         = 'ACTIVE_ASSIGN';
  --
  CURSOR csr_per_details
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT pet.person_type_id
          ,pet.system_person_type
          ,per.effective_start_date
          ,per.effective_end_date
          ,per.applicant_number
          ,per.employee_number
          ,per.npw_number
          ,bus.business_group_id
          ,bus.legislation_code
      FROM per_people_f per
          ,per_business_groups bus
          ,per_person_types pet
     WHERE per.person_type_id      = pet.person_type_id
       AND per.business_group_id+0 = bus.business_group_id
       AND per.person_id           = csr_per_details.p_person_id
       AND csr_per_details.p_effective_date BETWEEN per.effective_start_date
                                                AND per.effective_end_date;
  --
  CURSOR csr_apl_details
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT apl.application_id
          ,apl.object_version_number
      FROM per_applications apl
     WHERE apl.person_id = csr_apl_details.p_person_id
       AND csr_apl_details.p_effective_date BETWEEN apl.date_received
                                                AND NVL(apl.date_end,hr_api.g_eot);
  --
  CURSOR csr_pds_details
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT pds.period_of_service_id
          ,pds.object_version_number
      FROM per_periods_of_service pds
     WHERE pds.person_id = csr_pds_details.p_person_id
       AND csr_pds_details.p_effective_date BETWEEN pds.date_start
                                                AND NVL(pds.actual_termination_date,hr_api.g_eot);
--
-- -----------------------------------------------------------------------------
-- |--------------------------< future_asgs_count >----------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Determines the number of assignments for a person which start on or after
--   a date.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--   p_assignment_id                No   number   assignment_id if specified looks only for
--                                                future changes to that assignment
--
-- Post Success:
--   The number of assignments for the person starting on or after a date is
--   returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION future_asgs_count
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%type DEFAULT NULL --2264191 added
  )
RETURN INTEGER
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'future_asgs_count';
  --
  l_future_asgs_count            INTEGER := 0;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  FOR l_future_asgs_rec IN
  csr_future_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    )
  LOOP
     l_future_asgs_count := l_future_asgs_count + 1;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_future_asgs_count);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_future_asgs%ISOPEN
    THEN
      CLOSE csr_future_asgs;
    END IF;
    RAISE;
--
END future_asgs_count;
--
-- -----------------------------------------------------------------------------
-- |------------------------< nonaccepted_asgs_count >-------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Determines the number of non-accepted applicant assignments for a person
--   on a date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The number of non-accepted applicant assignments for the person on a date
--   is returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION nonaccepted_asgs_count
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN INTEGER
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'nonaccepted_asgs_count';
  --
  l_nonaccepted_asgs_count       INTEGER := 0;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  FOR l_nonaccepted_asgs_rec IN
  csr_nonaccepted_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    )
  LOOP
     l_nonaccepted_asgs_count := l_nonaccepted_asgs_count + 1;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_nonaccepted_asgs_count);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_nonaccepted_asgs%ISOPEN
    THEN
      CLOSE csr_nonaccepted_asgs;
    END IF;
    RAISE;
--
END nonaccepted_asgs_count;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< accepted_asgs_count >---------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Determines the number of accepted applicant assignments for a person on a
--   date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The number of accepted applicant assignments for the person on a date is
--   returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION accepted_asgs_count
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN INTEGER
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'accepted_asgs_count';
  --
  l_accepted_asgs_count          INTEGER := 0;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  FOR l_accepted_asgs_rec IN
  csr_accepted_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    )
  LOOP
     l_accepted_asgs_count := l_accepted_asgs_count + 1;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_accepted_asgs_count);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_accepted_asgs%ISOPEN
    THEN
      CLOSE csr_accepted_asgs;
    END IF;
    RAISE;
--
END accepted_asgs_count;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< primary_asgs_count >---------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Determines the number of primary employee assignments for a person on a
--   date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The number of primary employee assignments for the person on a date is
--   returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION primary_asgs_count
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN INTEGER
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'primary_asgs_count';
  --
  l_primary_asgs_count           INTEGER := 0;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  FOR l_primary_asgs_rec IN
  csr_primary_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    )
  LOOP
     l_primary_asgs_count := l_primary_asgs_count + 1;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_primary_asgs_count);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_primary_asgs%ISOPEN
    THEN
      CLOSE csr_primary_asgs;
    END IF;
    RAISE;
--
END primary_asgs_count;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< per_details >--------------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Retrieve details about a person on a date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The person details are returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION per_details
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN csr_per_details%ROWTYPE
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'per_details';
  --
  l_per_details_rec              csr_per_details%ROWTYPE;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  OPEN csr_per_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_per_details INTO l_per_details_rec;
  IF csr_per_details%NOTFOUND
  THEN
    hr_utility.set_location(l_proc,20);
    CLOSE csr_per_details;
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_per_details;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_per_details_rec);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_per_details%ISOPEN
    THEN
      CLOSE csr_per_details;
    END IF;
    RAISE;
END per_details;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< apl_details >--------------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Retrieve details about an application of a person on a date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The application details are returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION apl_details
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN csr_apl_details%ROWTYPE
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'apl_details';
  --
  l_apl_details_rec              csr_apl_details%ROWTYPE;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  OPEN csr_apl_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_apl_details INTO l_apl_details_rec;
  CLOSE csr_apl_details;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_apl_details_rec);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_apl_details%ISOPEN
    THEN
      CLOSE csr_apl_details;
    END IF;
    RAISE;
END apl_details;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< pds_details >--------------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Retrieve details about a period of service of a person on a date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The period of service details are returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION pds_details
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN csr_pds_details%ROWTYPE
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'pds_details';
  --
  l_pds_details_rec              csr_pds_details%ROWTYPE;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  OPEN csr_pds_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_pds_details INTO l_pds_details_rec;
  CLOSE csr_pds_details;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_pds_details_rec);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_pds_details%ISOPEN
    THEN
      CLOSE csr_pds_details;
    END IF;
    RAISE;
END pds_details;
--
-- -----------------------------------------------------------------------------
-- |--------------------< hire_to_employee_applicant OLD>----------------------|
-- -----------------------------------------------------------------------------
--   This procedure is overloaded to keep the parameters in line with the base
--   release
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'hire__to_employee_applicant';
  --
  l_per_object_version_number     per_all_people_f.object_version_number%TYPE;
  l_ovn per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_employee_number               per_all_people_f.employee_number%TYPE;
  l_per_effective_start_date      per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date        per_all_people_f.effective_end_date%TYPE;
  l_assign_payroll_warning        BOOLEAN;
  l_oversubscribed_vacancy_id     number;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_per_object_version_number:= p_per_object_version_number;
  l_employee_number:= p_employee_number;
  --
  hr_employee_applicant_api.hire_to_employee_applicant
  (p_validate                     => p_validate
  ,p_hire_date                    => p_hire_date
  ,p_person_id                    => p_person_id
  ,p_per_object_version_number    => l_per_object_version_number
  ,p_person_type_id               => p_person_type_id
  ,p_hire_all_accepted_asgs       => 'Y'   --2264191: this value replicates the old behaviour
  ,p_assignment_id                => p_assignment_id
  ,p_employee_number              => l_employee_number
  ,p_per_effective_start_date     => l_per_effective_start_date
  ,p_per_effective_end_date       => l_per_effective_end_date
  ,p_assign_payroll_warning       => l_assign_payroll_warning
  ,p_oversubscribed_vacancy_id    => l_oversubscribed_vacancy_id
  );
  --
  p_per_object_version_number:=l_per_object_version_number;
  p_employee_number:=l_employee_number;
  p_per_effective_start_date:=l_per_effective_start_date;
  p_per_effective_end_date:=l_per_effective_end_date;
  p_assign_payroll_warning:=l_assign_payroll_warning;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
end hire_to_employee_applicant;
--
-- -----------------------------------------------------------------------------
-- |--------------------< hire_to_employee_applicant OLD1>---------------------|
-- -----------------------------------------------------------------------------
--   This procedure is overloaded to keep the parameters in line with the previous
--   release
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       out nocopy number
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'hire__to_employee_applicant';
  --
  l_per_object_version_number     per_all_people_f.object_version_number%TYPE;
  l_ovn per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_employee_number               per_all_people_f.employee_number%TYPE;
  l_per_effective_start_date      per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date        per_all_people_f.effective_end_date%TYPE;
  l_assign_payroll_warning        BOOLEAN;
  l_oversubscribed_vacancy_id     number;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_per_object_version_number:= p_per_object_version_number;
  l_employee_number:= p_employee_number;
  --
  hr_employee_applicant_api.hire_to_employee_applicant
  (p_validate                     => p_validate
  ,p_hire_date                    => p_hire_date
  ,p_person_id                    => p_person_id
  ,p_per_object_version_number    => l_per_object_version_number
  ,p_person_type_id               => p_person_type_id
  ,p_hire_all_accepted_asgs       => 'Y'   --2264191: this value replicates the old behaviour
  ,p_assignment_id                => p_assignment_id
  ,p_employee_number              => l_employee_number
  ,p_per_effective_start_date     => l_per_effective_start_date
  ,p_per_effective_end_date       => l_per_effective_end_date
  ,p_assign_payroll_warning       => l_assign_payroll_warning
  ,p_oversubscribed_vacancy_id    => l_oversubscribed_vacancy_id
  );
  --
  p_per_object_version_number:=l_per_object_version_number;
  p_employee_number:=l_employee_number;
  p_per_effective_start_date:=l_per_effective_start_date;
  p_per_effective_end_date:=l_per_effective_end_date;
  p_assign_payroll_warning:=l_assign_payroll_warning;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
end hire_to_employee_applicant;
--
-- -----------------------------------------------------------------------------
-- |--------------------< hire_to_employee_applicant NEW >----------------------|
-- -----------------------------------------------------------------------------
--
PROCEDURE hire_to_employee_applicant
  (p_validate                     IN     BOOLEAN                                     DEFAULT FALSE
  ,p_hire_date                    IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        DEFAULT NULL
  ,p_hire_all_accepted_asgs       IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE    DEFAULT NULL
  ,p_national_identifier          IN     per_all_people_f.national_identifier%TYPE   DEFAULT hr_api.g_varchar2
  ,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
  ,p_per_effective_start_date        OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_per_effective_end_date          OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_oversubscribed_vacancy_id       out nocopy number
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'hire_to_employee_applicant';
  --
  l_hire_date                    DATE;
  l_ovn per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_person_type_id               per_person_types.person_type_id%TYPE     := p_person_type_id;
  l_person_type_id1              per_person_types.person_type_id%TYPE;
  --
  l_new_primary_asg_id           per_all_assignments_f.assignment_id%TYPE;
  l_hire_all_accepted_asgs       VARCHAR2(1);
  l_hire_single_asg_id           per_all_assignments_f.assignment_id%TYPE;
  --
  l_per_object_version_number    CONSTANT per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_employee_number              CONSTANT per_all_people_f.employee_number%TYPE       := p_employee_number;
  l_emp_num              CONSTANT per_all_people_f.employee_number%TYPE := p_employee_number;
  --
  l_per_effective_start_date     per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date       per_all_people_f.effective_end_date%TYPE;
  l_assign_payroll_warning       BOOLEAN;
  --
  l_system_person_type           per_person_types.system_person_type%TYPE;
  l_future_asgs_count            INTEGER;
  l_nonaccepted_asgs_count       INTEGER;
  l_accepted_asgs_count          INTEGER;
  l_primary_asgs_count           INTEGER;
  l_assignment_status_type_id    per_assignment_status_types.assignment_status_type_id%TYPE;
  l_primary_flag                 per_all_assignments_f.primary_flag%TYPE;
  --
  l_effective_start_date         DATE;
  l_effective_end_date           DATE;
  l_validation_start_date        DATE;
  l_validation_end_date          DATE;
  l_business_group_id            hr_all_organization_units.organization_id%TYPE;
  l_comment_id                   hr_comments.comment_id%TYPE;
  l_current_applicant_flag       per_all_people_f.current_applicant_flag%TYPE;
  l_current_emp_or_apl_flag      per_all_people_f.current_emp_or_apl_flag%TYPE;
  l_current_employee_flag        per_all_people_f.current_employee_flag%TYPE;
  l_full_name                    per_all_people_f.full_name%TYPE;
  l_name_combination_warning     BOOLEAN;
  l_orig_hire_warning            BOOLEAN;
  l_payroll_id_updated           BOOLEAN;
  l_other_manager_warning        BOOLEAN;
  l_no_managers_warning          BOOLEAN;
  l_org_now_no_manager_warning   BOOLEAN;
  l_hourly_salaried_warning      BOOLEAN;
  l_oversubscribed_vacancy_id    number;
  l_person_type_usage_id         per_person_type_usages.person_type_usage_id%TYPE;
  l_object_version_number        NUMBER := p_per_object_version_number; -- 3684087
  --
  l_per_details_rec              csr_per_details%ROWTYPE;
  l_pds_details_rec              csr_pds_details%ROWTYPE;
  l_accepted_asgs_rec            csr_accepted_asgs%ROWTYPE;
  --
  l_dummy                        number;
  --
  cursor csr_vacs(p_vacancy_id number) is
  select 1
  from per_all_vacancies vac
  where vac.vacancy_id=p_vacancy_id
  and vac.number_of_openings <
    (select count(distinct assignment_id)
     from per_all_assignments_f asg
     where asg.vacancy_id=p_vacancy_id
     and asg.assignment_type='E');
  --
  cursor csr_future_per_changes(p_effective_date DATE) is
  select 1 from dual where exists
  (select 1
   from per_all_people_f
   where person_id = p_person_id
   and effective_start_date >= p_effective_date);
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'hire_date'
    ,p_argument_value               => p_hire_date
    );
  --
  -- Truncate all date parameters passed in
  --
  l_hire_date := TRUNC(p_hire_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT hire_to_employee_applicant;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Get the derived details for the person on the hire date
  --
  l_per_details_rec := per_details
                         (p_person_id                    => p_person_id
                         ,p_effective_date               => l_hire_date
                         );
  --
  hr_utility.set_location(l_proc,40);
  --
  -- 2264191 changed behaviour: single asg hire requires the assignment id.
  -- only hire all accepted if passed the 'Y' flag, not for any other value
  -- 'Y' replicates the old behaviour
  --
  IF p_hire_all_accepted_asgs is null
  OR (    p_hire_all_accepted_asgs <> 'Y'
      AND p_hire_all_accepted_asgs is not null)
  THEN
      hr_utility.set_location(l_proc,45);
      l_hire_all_accepted_asgs := 'N';
      l_hire_single_asg_id := p_assignment_id;
      hr_api.mandatory_arg_error
        (p_api_name                     => l_proc
        ,p_argument                     => 'assignment_id'
        ,p_argument_value               => p_assignment_id);
  ELSE
      l_hire_all_accepted_asgs := 'Y';
      l_hire_single_asg_id := -1;
  END IF;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_employee_applicant_bk1.hire_to_employee_applicant_b
      (p_hire_date                    => l_hire_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_person_type_id               => p_person_type_id
      ,p_hire_all_accepted_asgs       => p_hire_all_accepted_asgs
      ,p_assignment_id                => p_assignment_id
      ,p_per_object_version_number    => p_per_object_version_number
      ,p_national_identifier          => p_national_identifier
      ,p_employee_number              => p_employee_number
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_TO_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'BP'
        );
  END;
  --
  hr_utility.set_location(l_proc,50);
  --
  -- Check the person is of a correct system person type
  --
  IF l_per_details_rec.system_person_type NOT IN
     ('APL','EMP_APL','EX_EMP_APL','APL_EX_APL')
  THEN
    hr_utility.set_location(l_proc,60);
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,70);
  --
  -- Ensure the employee number will not be changed if it exists
  --
  IF    l_per_details_rec.employee_number IS NOT NULL
    AND NVL(p_employee_number,hr_api.g_number) <> l_per_details_rec.employee_number
  THEN
     hr_utility.set_location(l_proc,80);
     p_employee_number := l_per_details_rec.employee_number;
  END IF;
  --
  hr_utility.set_location(l_proc,90);
  --
  -- Check the person does not have future assignment changes
  --
  IF l_hire_all_accepted_asgs = 'Y' then
    l_future_asgs_count := future_asgs_count
                             (p_person_id                    => p_person_id
                             ,p_effective_date               => l_hire_date
                             );
  ELSE  --2264191 added this clause to enhance error handling
    l_future_asgs_count := future_asgs_count
                             (p_person_id                    => p_person_id
                             ,p_effective_date               => l_hire_date
                             ,p_assignment_id                => p_assignment_id
                             );
  END IF;
  IF l_future_asgs_count > 0
  THEN
    hr_utility.set_location(l_proc,100);
    hr_utility.set_message(800,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,110);
  --
  -- If person type id is not null check it corresponds to type EMP_APL is
  -- currently active and in the correct business group, otherwise set person
  -- type id to the active default for EMP_APL in the correct business group
  --
  l_system_person_type := 'EMP_APL';

/* PTU changes: move this validation as now flavour of EMP must be specified
                now check before maintain_person_type_usage_call
  per_per_bus.chk_person_type
    (p_person_type_id               => l_person_type_id
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_expected_sys_type            => l_system_person_type
    );
*/  --
  hr_utility.set_location(l_proc,120);
  --
  -- 2264191 changed behaviour: If hiring all accepted, ensure there are some nonaccepted
  -- applicant assignments that will remain for the person to be an applicant for.
  --
  l_nonaccepted_asgs_count := nonaccepted_asgs_count
                                (p_person_id                    => p_person_id
                                ,p_effective_date               => l_hire_date
                                );
  IF l_nonaccepted_asgs_count = 0
  AND l_hire_all_accepted_asgs = 'Y'
  THEN
    hr_utility.set_location(l_proc,130);
    hr_utility.set_message(800,'HR_289149_NOHIR_NO_UNACCEPTED'); --'PER_52098_APL_INV_ASG_STATUS');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,140);
  --
  -- Ensure there are some accepted applicant assignments for the person to be
  -- hired into (applies pre and post 2264191)
  --
  l_accepted_asgs_count := accepted_asgs_count
                             (p_person_id                    => p_person_id
                             ,p_effective_date               => l_hire_date
                             );
  IF l_accepted_asgs_count = 0
  THEN
    hr_utility.set_location(l_proc,150);
    hr_utility.set_message(800,'HR_289150_NOHIR_NO_ACCEPTED'); --'PER_52098_APL_INV_ASG_STATUS');
    hr_utility.raise_error;
  END IF;
  --
  -- 2264191 changed behaviour: If hiring a single assignment
  -- ensure that there is more than one APL assignment to retain
  --
  IF l_hire_all_accepted_asgs = 'N'
  AND l_accepted_asgs_count + l_nonaccepted_asgs_count < 2
  THEN
    hr_utility.set_location(l_proc,155);
    hr_utility.set_message(800,'HR_289151_NOHIR_SGL_NO_RETAIN');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,160);
  --
  -- 2264191 changed behaviour: Ensure the assignment id has been set
  -- if either no current primary employee
  -- assignment and multiple accepted applicant assignment exist, or if hiring a single
  -- assignment and no current primary employee assignments exist.
  -- Ensure it is null if a primary employee assignment already exists.
  --
  l_primary_asgs_count := primary_asgs_count
                            (p_person_id                    => p_person_id
                            ,p_effective_date               => l_hire_date
                            );
  IF l_primary_asgs_count = 0
  AND l_hire_all_accepted_asgs = 'Y'     --replicate the behaviour pre2264191
  THEN
    hr_utility.set_location(l_proc,170);
    IF p_assignment_id IS NULL
    THEN
      hr_utility.set_location(l_proc,180);
      IF l_accepted_asgs_count = 1
      THEN
        hr_utility.set_location(l_proc,190);
        OPEN csr_accepted_asgs
          (p_person_id                    => p_person_id
          ,p_effective_date               => l_hire_date
          );
        FETCH csr_accepted_asgs INTO l_accepted_asgs_rec;
        CLOSE csr_accepted_asgs;
        l_new_primary_asg_id := l_accepted_asgs_rec.assignment_id;
      ELSE
        hr_utility.set_location(l_proc,200);
        hr_api.mandatory_arg_error
          (p_api_name                     => l_proc
          ,p_argument                     => 'assignment_id'
          ,p_argument_value               => p_assignment_id);
      END IF;
    ELSE
      l_new_primary_asg_id := p_assignment_id;
    END IF;
  ELSIF l_primary_asgs_count = 0        --2264191 hiring single asg, must make it primary
  AND   l_hire_all_accepted_asgs = 'N'
  THEN
    hr_utility.set_location(l_proc,205);
    l_new_primary_asg_id := p_assignment_id;
  ELSE                                  -- a primary already exists
    hr_utility.set_location(l_proc,210);
    --IF p_assignment_id IS NOT NULL
    --THEN
      hr_utility.set_location(l_proc,220);
      l_new_primary_asg_id := NULL;
    --END IF;
  END IF;
  --
  hr_utility.set_location(l_proc,230);
  --
  -- Ensure any assignment id specified is for the person, has an assignment
  -- type of A and a system status of ACCEPTED on the hire date
  --
  IF p_assignment_id IS NOT NULL
  THEN
    hr_utility.set_location(l_proc,240);
    OPEN csr_accepted_asgs
      (p_person_id                    => p_person_id
      ,p_effective_date               => l_hire_date
      ,p_assignment_id                => p_assignment_id
      );
    FETCH csr_accepted_asgs INTO l_accepted_asgs_rec;
    IF csr_accepted_asgs%NOTFOUND
    THEN
      hr_utility.set_location(l_proc,250);
      CLOSE csr_accepted_asgs;
      hr_utility.set_message(800,'HR_289152_NOHIR_ACCEPT_APL_ASG'); --'PER_52099_ASG_INV_ASG_ID');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_accepted_asgs;
  END IF;
  --
  hr_utility.set_location(l_proc,260);
  --
-- PTU : Changes

  l_person_type_id1  := hr_person_type_usage_info.get_default_person_type_id
                                        (l_per_details_rec.business_group_id,
                                         'EMP_APL');
-- PTU : End of Changes

  -- Update the person details to the new person type, if it has changed
  --
  IF l_per_details_rec.person_type_id <> l_person_type_id1
  THEN
    hr_utility.set_location(l_proc,270);
          --2931560 added check for future person changes
    open csr_future_per_changes(l_hire_date);
    fetch csr_future_per_changes into l_dummy;
    if csr_future_per_changes%found then
      close csr_future_per_changes;
--      hr_utility.set_message('PER','HR_289729_FUT_PER_NOHIR');
      hr_utility.set_message(800,'HR_289729_FUT_PER_NOHIR');  -- Bug 2931560
      hr_utility.raise_error;
    else
      close csr_future_per_changes;
    end if;
    --
    per_per_upd.upd
      (p_person_id                    => p_person_id
      ,p_effective_start_date         => l_per_effective_start_date
      ,p_effective_end_date           => l_per_effective_end_date
      ,p_person_type_id               => l_person_type_id1
      ,p_applicant_number             => l_per_details_rec.applicant_number
      ,p_comment_id                   => l_comment_id
      ,p_current_applicant_flag       => l_current_applicant_flag
      ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
      ,p_current_employee_flag        => l_current_employee_flag
      ,p_employee_number              => p_employee_number
      ,p_full_name                    => l_full_name
      ,p_national_identifier          => p_national_identifier
      ,p_object_version_number        => l_object_version_number  -- 3684087
      ,p_effective_date               => l_hire_date
      ,p_datetrack_mode               => hr_api.g_update
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_dob_null_warning             => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
      ,p_npw_number                   => l_per_details_rec.npw_number
      );
  ELSE
    hr_utility.set_location(l_proc,280);
    l_per_effective_start_date := l_per_details_rec.effective_start_date;
    l_per_effective_end_date   := l_per_details_rec.effective_end_date;
  END IF;
  --
--
  hr_utility.set_location(l_proc,290);
  --
  -- Derive the current period of service, and create one if it does not exist
  --
  l_pds_details_rec := pds_details
                         (p_person_id                    => p_person_id
                         ,p_effective_date               => l_hire_date
                         );
  IF l_pds_details_rec.period_of_service_id IS NULL
  THEN
    hr_utility.set_location(l_proc,300);
    per_pds_ins.ins
      (p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_date_start                   => l_hire_date
      ,p_effective_date               => l_hire_date
      ,p_period_of_service_id         => l_pds_details_rec.period_of_service_id
      ,p_object_version_number        => l_pds_details_rec.object_version_number
      ,p_validate_df_flex             => false      -- fix for bug 8587538
      );
  END IF;
  --
-- PTU : Following Code has been added
--
  begin
    select ptuf.person_type_id into l_person_type_id1
    from per_person_type_usages_f ptuf, per_person_types ppt
    where ptuf.person_id = p_person_id
    and l_hire_date between ptuf.effective_start_date and ptuf.effective_end_date
    and ppt.person_type_id = ptuf.person_type_id
    and ppt.system_person_type = 'EMP';
  exception
    when no_data_found then
      l_person_type_id1 := null;   --added for 2264191, to refine the following IF clause
  end;
  --
  --  IF l_pds_details_rec.period_of_service_id IS NULL
  --    OR (l_pds_details_rec.period_of_service_id IS NOT NULL
  --        AND l_person_type_id <> l_person_type_id1)
  --
  -- 2264191 Refined this check
  --
  IF (l_person_type_id1 is null)            -- inserting
    OR (l_person_type_id1 is not null       -- updating with a change in PTU
        AND nvl(l_person_type_id,l_person_type_id1) <> l_person_type_id1)
    THEN
   per_per_bus.chk_person_type
    (p_person_type_id               => l_person_type_id
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_expected_sys_type            => 'EMP'
    );
  --
    hr_per_type_usage_internal.maintain_person_type_usage
    (p_effective_date        => l_hire_date
    ,p_person_id             => p_person_id
    ,p_person_type_id        => l_person_type_id
    );
  END IF;
--
-- PTU : End of changes
--
  hr_utility.set_location(l_proc,310);
  --
  -- Derive assignment status type id for default system status type of
  -- ACTIVE_ASSIGN for this business group
  --
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_legislation_code             => l_per_details_rec.legislation_code
    ,p_expected_system_status       => 'ACTIVE_ASSIGN'
    );
  --
  hr_utility.set_location(l_proc,320);
  --
  l_oversubscribed_vacancy_id :=null;
  --
  -- 2264191 changed behaviour: If p_hire_all_accepted_asgs = 'Y' then
  -- set all accepted assignments to be active assignments, marking the
  -- assignment specified to be the primary assignment
  -- ELSE single hire only processes the specified assignment it has already been marked
  -- primary if no employee primaries exist
  --
  FOR l_accepted_asgs_rec IN
  csr_accepted_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => l_hire_date
    )
  LOOP
    l_primary_flag := 'N';
    IF l_accepted_asgs_rec.assignment_id = l_new_primary_asg_id
    THEN
      l_primary_flag := 'Y';
    END IF;
    IF l_hire_all_accepted_asgs = 'Y'
    OR (    l_hire_all_accepted_asgs = 'N'
        AND l_hire_single_asg_id = l_accepted_asgs_rec.assignment_id)
    THEN
    --
    -- 2264191 only process the assignment (in all cases it has to be accepted anyway)
    -- if we are processing all assignments
    -- or if processing one and the assignment_id matches
    --
       per_asg_upd.upd
	 (p_assignment_id                => l_accepted_asgs_rec.assignment_id
	 ,p_effective_start_date         => l_effective_start_date
	 ,p_effective_end_date           => l_effective_end_date
	 ,p_business_group_id            => l_business_group_id
	 ,p_assignment_status_type_id    => l_assignment_status_type_id
	 ,p_assignment_type              => 'E'
	 ,p_primary_flag                 => l_primary_flag
	 ,p_period_of_service_id         => l_pds_details_rec.period_of_service_id
	 ,p_comment_id                   => l_comment_id
	 ,p_object_version_number        => l_accepted_asgs_rec.object_version_number
	 ,p_payroll_id_updated           => l_payroll_id_updated
	 ,p_other_manager_warning        => l_other_manager_warning
	 ,p_no_managers_warning          => l_no_managers_warning
	 ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
	 ,p_validation_start_date        => l_validation_start_date
	 ,p_validation_end_date          => l_validation_end_date
	 ,p_effective_date               => l_hire_date
	 ,p_datetrack_mode               => hr_api.g_update
	 ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	 );
       --
       open csr_vacs(l_accepted_asgs_rec.vacancy_id);
       fetch csr_vacs into l_dummy;
       if csr_vacs%found then
	 close csr_vacs;
	 l_oversubscribed_vacancy_id :=l_accepted_asgs_rec.vacancy_id;
       else
	 close csr_vacs;
       end if;
       --
    END IF;   --end of test if processing all asgs or matching single asg
  END LOOP;
  --
  hr_utility.set_location(l_proc,325);
  --
  -- Maintain person type usage record
  --
/* Removed for PTU changes, since covered by previous call to maintain
  hr_per_type_usage_internal.create_person_type_usage
    (p_effective_date               => l_hire_date
    ,p_person_id                    => p_person_id
    ,p_person_type_id               => l_person_type_id
    ,p_person_type_usage_id         => l_person_type_usage_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_object_version_number        => l_object_version_number
    );
*/
  --
  hr_utility.set_location(l_proc,330);
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_employee_applicant_bk1.hire_to_employee_applicant_a
      (p_hire_date                    => l_hire_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_person_type_id               => p_person_type_id
      ,p_hire_all_accepted_asgs       => p_hire_all_accepted_asgs
      ,p_assignment_id                => p_assignment_id
      ,p_per_object_version_number    => p_per_object_version_number
      ,p_national_identifier          => p_national_identifier
      ,p_employee_number              => p_employee_number
      ,p_per_effective_start_date     => l_per_effective_start_date
      ,p_per_effective_end_date       => l_per_effective_end_date
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_oversubscribed_vacancy_id    => l_oversubscribed_vacancy_id
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_TO_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'AP'
        );
  END;
  --
  hr_utility.set_location(l_proc,340);
  --
  -- When in validation only mode raise validate_enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_per_object_version_number    := l_object_version_number;  -- 3684087
  p_employee_number              := l_employee_number;
  p_per_effective_start_date     := l_per_effective_start_date;
  p_per_effective_end_date       := l_per_effective_end_date;
  p_assign_payroll_warning       := l_assign_payroll_warning;
  p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
  --
  hr_utility.set_location(' Leaving:'||l_proc,1000);
--
EXCEPTION
  --
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO hire_to_employee_applicant;
    p_per_object_version_number    := l_per_object_version_number;
    p_employee_number              := l_employee_number;
    p_per_effective_start_date     := NULL;
    p_per_effective_end_date       := NULL;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Ensure opened non-local cursors are closed
    -- Rollback to savepoint
    -- Re-raise exception
    --
    ROLLBACK TO hire_to_employee_applicant;
    --
    -- set in out parameters and set out parameters
    --
    p_per_object_version_number    := l_ovn;
    p_employee_number              := l_emp_num;
    p_per_effective_start_date     := NULL;
    p_per_effective_end_date       := NULL;
    p_assign_payroll_warning       := false;
    p_oversubscribed_vacancy_id    := null;
    --
    IF csr_accepted_asgs%ISOPEN
    THEN
      CLOSE csr_accepted_asgs;
    END IF;
    RAISE;
--
END hire_to_employee_applicant;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >---------------------|
-- ---------------------------------------------------------------------------
--   This procedure is overloaded to keep the parameters in line with the base
--   release
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_person_type_id            in      number   default null,
   p_assignment_id             in      number   default null,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'hire__employee_applicant';
  --
  l_per_object_version_number      per_all_people_f.object_version_number%TYPE;
  l_per_effective_start_date       date;
  l_per_effective_end_date         date;
  l_unaccepted_asg_del_warning     boolean;
  l_assign_payroll_warning         boolean;
  l_oversubscribed_vacancy_id      number;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_per_object_version_number:=p_per_object_version_number;
  --
  hr_employee_applicant_api.hire_employee_applicant
  (p_validate                   => p_validate
  ,p_hire_date                  => p_hire_date
  ,p_person_id                  => p_person_id
  ,p_primary_assignment_id      => p_assignment_id
  ,p_person_type_id             => p_person_type_id
  ,p_per_object_version_number  => l_per_object_version_number
  ,p_per_effective_start_date   => l_per_effective_start_date
  ,p_per_effective_end_date     => l_per_effective_end_date
  ,p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning
  ,p_assign_payroll_warning     => l_assign_payroll_warning
  ,p_oversubscribed_vacancy_id  => l_oversubscribed_vacancy_id
  );
  p_per_object_version_number  := l_per_object_version_number;
  p_per_effective_start_date   := l_per_effective_start_date;
  p_per_effective_end_date     := l_per_effective_end_date;
  p_unaccepted_asg_del_warning := l_unaccepted_asg_del_warning;
  p_assign_payroll_warning     := l_assign_payroll_warning;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
end hire_employee_applicant;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >---------------------|
-- ---------------------------------------------------------------------------
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_primary_assignment_id     in      number   default null,
   p_person_type_id            in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
  ,p_oversubscribed_vacancy_id    out nocopy  number
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'hire_employee_applicant';
  --
  l_exists                     varchar2(1);
  l_count                      number;
  l_chk_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_chk_person_id              per_all_people_f.person_id%TYPE;
  --
  l_person_type_id             number   :=  p_person_type_id;
  l_person_type_id1            number;
  l_unaccepted_asg_del_warning boolean;
  --
  l_primary_assignment_id number:=p_primary_assignment_id;
  --
  l_system_person_type         per_person_types.system_person_type%TYPE;
  l_business_group_id          per_all_people_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_application_id             per_applications.application_id%TYPE;
  l_apl_object_version_number  per_applications.application_id%TYPE;
  --
  l_hire_date                  date;
  --
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_asg_object_version_number  per_assignments_f.object_version_number%TYPE;
  --
  l_per_object_version_number  per_all_people_f.object_version_number%TYPE;
  l_ovn per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_employee_number            per_all_people_f.employee_number%TYPE;
  l_applicant_number           per_all_people_f.applicant_number%TYPE;
  l_npw_number                 per_all_people_f.npw_number%TYPE;
  l_per_effective_start_date   per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date     per_all_people_f.effective_end_date%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_name_combination_warning   boolean;
  l_assign_payroll_warning     boolean;
  l_orig_hire_warning          boolean;
  l_oversubscribed_vacancy_id  number;
  --Added for 5277866
  l_check_loop                 number:=0;
  --
  l_period_of_service_id       per_periods_of_service.period_of_service_id%TYPE;
  l_pds_object_version_number  per_periods_of_service.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  --
  l_primary_flag               per_assignments_f.primary_flag%TYPE;
  --
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_payroll_id_updated         boolean;
  l_other_manager_warning      boolean;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  l_hourly_salaried_warning    boolean;
  l_datetrack_update_mode      varchar2(30);
  --
  l_primary_asg_id             per_all_assignments_f.assignment_id%type;
  l_primary_ovn                per_all_assignments_f.object_version_number%type;
  l_dummy number;
  l_dummy1 number;
  l_dummy2 number;
  l_dummyv varchar2(700);
  l_dummyb boolean;
-- 2788390 starts here
  l_dummynum1  number;
-- 2788390 ends here
--added as per bug 5102160
l_gsp_post_process_warning     varchar2(2000); -- bug2999562
l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
--
  --
  cursor csr_future_asg_changes is
    select 'x'
      from per_assignments_f asg
     where asg.person_id = p_person_id
       and asg.effective_start_date > p_hire_date;
  --
  cursor csr_get_devived_details is
    select per.effective_start_date,
           ppt.system_person_type,
           per.business_group_id,
           bus.legislation_code,
           per.employee_number,
           per.npw_number,
           pap.application_id,
           pap.object_version_number
      from per_all_people_f per,
           per_business_groups bus,
           per_person_types ppt,
           per_applications pap
     where per.person_type_id    = ppt.person_type_id
       and per.business_group_id = bus.business_group_id
       and per.person_id         = pap.person_id
       and per.person_id         = p_person_id
       and l_hire_date       between per.effective_start_date
                               and per.effective_end_date
       and l_hire_date       between pap.date_received
                               and nvl(pap.date_end,hr_api.g_eot);
  --
  cursor csr_chk_asg_status is
    select count(asg.assignment_id)
      from per_assignments_f asg,
	   per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and pas.per_system_status         = 'ACCEPTED'
       and l_hire_date             between asg.effective_start_date
 		                                   and asg.effective_end_date;
  --
  cursor csr_chk_assignment_id is
    select per.person_id,
           pas.per_system_status
      from per_all_people_f per,
           per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and per.person_id                 = asg.person_id
       and l_hire_date             between per.effective_start_date
                                       and per.effective_end_date
       and asg.assignment_id             = p_primary_assignment_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date;
  --
  cursor csr_get_un_accepted is
    select asg.assignment_id,
	   asg.object_version_number
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and asg.assignment_type='A'
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status        <> 'ACCEPTED'
     order by asg.assignment_id;
  --
  /*
  cursor csr_get_accepted is
    select asg.assignment_id,
	   asg.object_version_number,
           asg.effective_start_date,
           asg.vacancy_id
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
     order by asg.assignment_id;
     */
      -- modified the above cursor for the bug 5534570
  cursor csr_get_accepted is
    select asg.assignment_id,
	   asg.object_version_number,
           asg.effective_start_date,
           asg.vacancy_id

	 from per_assignments_f asg,
         per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
       order by decode(asg.assignment_id,p_primary_assignment_id,1,0) desc;
--
  --
  cursor get_primary is
  select assignment_id,object_version_number, period_of_service_id -- #2468916
  from per_all_assignments_f
  where person_id=p_person_id
  and primary_flag='Y'
  and l_hire_date between effective_start_date and effective_end_date
  and assignment_type='E';
  --
  cursor get_asg(p_assignment_id number) is
    select *
    from per_all_assignments_f asg
    where asg.assignment_id=p_assignment_id
    and l_hire_date between asg.effective_start_date
                    and asg.effective_end_date;
  --
  l_asg_rec per_all_assignments_f%rowtype;
  l_primary_asg_rec per_all_assignments_f%rowtype;
  --
  cursor get_pgp(p_people_group_id number) is
    select *
    from pay_people_groups
    where people_group_id=p_people_group_id;
  --
  l_pgp_rec pay_people_groups%rowtype :=NULL;
  l_primary_pgp_rec pay_people_groups%rowtype;
  --
  cursor get_scl(p_soft_coding_keyflex_id number) is
  select *
  from hr_soft_coding_keyflex
  where soft_coding_keyflex_id=p_soft_coding_keyflex_id;
  --
  l_scl_rec hr_soft_coding_keyflex%rowtype :=NULL;
  l_primary_scl_rec hr_soft_coding_keyflex%rowtype :=NULL;
  --
  cursor get_cag(p_cagr_grade_def_id number) is
  select *
  from per_cagr_grades_def
  where cagr_grade_def_id=p_cagr_grade_def_id;
  --
  l_cag_rec per_cagr_grades_def%rowtype :=NULL;
  l_primary_cag_rec per_cagr_grades_def%rowtype;
  --
  cursor csr_vacs(p_vacancy_id number) is
  select 1
  from per_all_vacancies vac
  where vac.vacancy_id=p_vacancy_id
  and vac.number_of_openings <
    (select count(distinct assignment_id)
     from per_all_assignments_f asg
     where asg.vacancy_id=p_vacancy_id
     and asg.assignment_type='E');
--
-- Bug 4644830 Start
    cursor get_pay_proposal(ass_id per_all_assignments_f.assignment_id%type) is
    select pay_proposal_id,object_version_number,proposed_salary_n, change_date, proposal_reason -- Added For Bug 5987409 --
    from per_pay_proposals
    where assignment_id=ass_id
    and   approved = 'N'
    order by change_date desc;
    l_pay_pspl_id     per_pay_proposals.pay_proposal_id%TYPE;
    l_pay_obj_number  per_pay_proposals.object_version_number%TYPE;
    l_proposed_sal_n  per_pay_proposals.proposed_salary_n%TYPE;
    l_dummy_change_date per_pay_proposals.change_date%TYPE;
    l_inv_next_sal_date_warning  boolean := false;
    l_proposed_salary_warning  boolean := false;
    l_approved_warning  boolean := false;
    l_payroll_warning  boolean := false;
    l_proposal_reason per_pay_proposals.proposal_reason%TYPE; -- Added For Bug 5987409 --
-- Bug 4644830 End
--
-- start of bug 4641965
l_pspl_asg_id per_all_assignments_f.assignment_id%type;
cursor get_primary_proposal(ass_id per_all_assignments_f.assignment_id%type) is
     select pay_proposal_id,object_version_number
     from per_pay_proposals
     where assignment_id=ass_id
     and APPROVED='N';
 -- end 4641965

--Bug 4959033 starts here

  cursor get_business_group(p_asg_id number) is
  select distinct PAAF.business_group_id
  from   per_all_assignments_f PAAF
  where  PAAF.assignment_id=p_asg_id;
  l_bg_id number;

  cursor get_primary_approved_proposal(ass_id per_all_assignments_f.assignment_id%type) is
  select pay_proposal_id
  from per_pay_proposals
  where assignment_id=ass_id
  and APPROVED='Y';

--Bug 4959033 ends here
--
--Bug 5102289 starts here
  l_pay_basis_id  per_all_assignments_f.pay_basis_id%type;
  l_approved varchar2(10);
  cursor get_primary_pay_basis(p_asg_id number) is
         select PAAF.pay_basis_id
         from per_all_assignments_f PAAF
         where PAAF.assignment_id=p_asg_id;
--Bug 5102289 ends here
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'hire_date'
     ,p_argument_value => p_hire_date
     );
  --
  -- Issue a savepoint.
  --
  savepoint hire_employee_applicant;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Truncate the time portion from all date parameters
  -- which are passed in.
  --
  l_hire_date                  := trunc(p_hire_date);
  l_per_object_version_number:=p_per_object_version_number;
  --
  -- Call Before Process User Hook for hire_applicant
  --
  begin
    hr_employee_applicant_bk2.hire_employee_applicant_b
      (
       p_hire_date                 => l_hire_date,
       p_person_id                 => p_person_id,
       p_primary_assignment_id     => p_primary_assignment_id,
       p_overwrite_primary         => p_overwrite_primary,
       p_person_type_id            => p_person_type_id,
       p_per_object_version_number => l_per_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for hire_employee_applicant
  --
  end;
  --
  -- Check that there are not any future changes to the assignment
  --
  hr_utility.set_location(l_proc, 30);
  --
  open csr_future_asg_changes;
  fetch csr_future_asg_changes into l_exists;
  --
  if csr_future_asg_changes%FOUND then
    --
    hr_utility.set_location(l_proc,40);
    close csr_future_asg_changes;
    --
    hr_utility.set_message(801,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc,45);
  --
  -- Get the derived details for the person DT instance
  --
  open  csr_get_devived_details;
  fetch csr_get_devived_details
   into l_per_effective_start_date,
        l_system_person_type,
        l_business_group_id,
        l_legislation_code,
        l_employee_number,
        l_npw_number,
        l_application_id,
        l_apl_object_version_number;
  if csr_get_devived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc,50);
    --
    close csr_get_devived_details;
    --
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
    --
  end if;
  close csr_get_devived_details;
  --
  hr_utility.set_location(l_proc,55);
  --
  -- Validation in addition to Row Handlers
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'EMP', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for EMP
  -- in the current business group.
  --
   per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => l_business_group_id
    ,p_expected_sys_type => 'EMP'
    );
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Check that corresponding person is of 'EMP_APL'
  -- system person type.
  --
  if l_system_person_type <> 'EMP_APL'
  then
    --
    hr_utility.set_location(l_proc,70);
    --
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- Check that corresponding person is of 'ACCEPTED' of
  -- assignment status type.
  --
  open csr_chk_asg_status;
  fetch csr_chk_asg_status into l_count;
  --close csr_chk_asg_status; -- Bug 3266844. Commented out.
  --
  if l_count = 0 then
     --
     hr_utility.set_location(l_proc,90);
     --
     close csr_chk_asg_status;
     --
     hr_utility.set_message(800,'PER_52098_APL_INV_ASG_STATUS');
     hr_utility.raise_error;
     --
  end if;
  --
  close csr_chk_asg_status;  -- Bug 3266844. Added.
  -- If we are overwriting the primary, the new primary id
  -- must be not null.
  --
  if p_overwrite_primary='Y' then
    --
    hr_utility.set_location(l_proc,100);
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_primary_assignment_id
    );
    --
    hr_utility.set_location(l_proc,110);
 else
   --the primary assignment id should be null
   l_primary_assignment_id:=null;
   hr_utility.set_location(l_proc,115);
    --
  end if;
  --
  hr_utility.set_location(l_proc,120);
  --
  -- Check p_assignment is corresponding data.
  -- The assignment record specified by P_ASSIGNMENT_ID on the hire
  -- date in the PER_ASSIGNMENTS_F table has assignment status
  -- 'ACCEPTED'.
  --
  if p_primary_assignment_id is not null then
    --
    hr_utility.set_location(l_proc,130);
    --
    open  csr_chk_assignment_id;
    fetch csr_chk_assignment_id
     into l_chk_person_id,
          l_chk_system_status;
    if csr_chk_assignment_id%NOTFOUND then
       --
       hr_utility.set_location(l_proc,140);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52099_ASG_INV_ASG_ID');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_person_id <> p_person_id then
       --
       hr_utility.set_location(l_proc,150);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52101_ASG_INV_PER_ID_COMB');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_system_status <> 'ACCEPTED' then
       --
       hr_utility.set_location(l_proc,155);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52100_ASG_INV_PER_TYPE');
       hr_utility.raise_error;
       --
    end if;
    --
    hr_utility.set_location(l_proc,160);
    --
    close csr_chk_assignment_id;
    --
  end if;
  --
  hr_utility.set_location(l_proc,170);
  --
  -- Lock the person record in PER_ALL_PEOPLE_F ready for UPDATE at a later point.
  -- (Note: This is necessary because calling the table handlers in locking
  --        ladder order invokes an error in per_apl_upd.upd due to the person
  --        being modified by the per_per_upd.upd table handler.)
  if l_per_effective_start_date=l_hire_date then
    l_datetrack_update_mode:='CORRECTION';
  else
    l_datetrack_update_mode:='UPDATE';
  end if;
  --
  per_per_shd.lck
    (p_effective_date                 => l_hire_date
    ,p_datetrack_mode                 => l_datetrack_update_mode
    ,p_person_id                      => p_person_id
    ,p_object_version_number          => l_per_object_version_number
    ,p_validation_start_date          => l_validation_start_date
    ,p_validation_end_date            => l_validation_end_date
    );
  --
  hr_utility.set_location(l_proc,180);
  --
  -- Update the application details by calling the upd procedure in the
  -- application table handler:
  -- Date_end is set to l_hire_date - 1;
  --
  per_apl_upd.upd
  (p_application_id                    => l_application_id
  ,p_date_end			       => l_hire_date - 1
  ,p_object_version_number             => l_apl_object_version_number
  ,p_effective_date                    => l_hire_date-1
  ,p_validate                          => false
  );
  hr_utility.set_location(l_proc,190);
  --
  -- Set all unaccepted applicant assignments to have end date = p_hire_date -1
  -- by calling the del procedure in the PER_ASSIGNMENTS_F table handler
  -- (This is a datetrack DELETE mode operation)
  --
  open csr_get_un_accepted;
  loop
    fetch csr_get_un_accepted
     into  l_assignment_id,
           l_asg_object_version_number;
    exit when csr_get_un_accepted%NOTFOUND;
    --
    hr_utility.set_location(l_proc,200);
    --
    per_asg_del.del
    (p_assignment_id              => l_assignment_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_business_group_id          => l_business_group_id
    ,p_object_version_number	  => l_asg_object_version_number
    ,p_effective_date             => l_hire_date-1
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_datetrack_mode             => 'DELETE'
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    );
    --
    hr_utility.set_location(l_proc,210);
    --
    l_unaccepted_asg_del_warning := TRUE;
    --
  end loop;
  --
  close csr_get_un_accepted;
  --
  hr_utility.set_location(l_proc, 220);

-- PTU : Changes

  l_person_type_id1   := hr_person_type_usage_info.get_default_person_type_id
                                         (l_business_group_id,
                                          'EMP');
-- PTU : End of Changes

  hr_utility.set_location(l_proc, 225);

  --
  -- Update the person details by calling upd procedure in
  -- the per_all_people_f table.
  --
  l_applicant_number:=hr_api.g_varchar2;
  l_employee_number:=hr_api.g_varchar2;
  per_per_upd.upd
  (p_person_id                    => p_person_id
  ,p_effective_date               => l_hire_date
  ,p_applicant_number             => l_applicant_number
  ,p_employee_number              => l_employee_number
  ,p_person_type_id               => l_person_type_id1
  ,p_object_version_number        => l_per_object_version_number
  ,p_datetrack_mode               => l_datetrack_update_mode
  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  ,p_npw_number                   => l_npw_number
  );
  --
  hr_utility.set_location(l_proc,230);

-- PTU : Following Code has been added
--
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => p_person_id
,p_person_type_id       => l_person_type_id
,p_datetrack_update_mode => l_datetrack_update_mode
);
--
  l_person_type_id1  := hr_person_type_usage_info.get_default_person_type_id
                                        (l_business_group_id,
                                         'EX_APL');
--
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => p_person_id
,p_person_type_id       => l_person_type_id1
,p_datetrack_update_mode => l_datetrack_update_mode
);
--
-- PTU : End of changes


  --
  --  All accepted applicant assignments are changed to employee assignments
  --  with default employee assignment.(ACTIVE_ASSIGN)
  --  1) Derive assignment_status_type_id for default 'ACTIVE_ASSIGN'.
  --  2) Update the assignments by calling the upd procedure in the
  --     PER_ASSIGNMENTS_F table handler(This is a datetrack UPDATE mode
  --     operation)
  --  3) When the accepted assignments are multiple, the primary flag of the
  --     record not specified by P_ASSIGNMENT_ID is set to 'N'.
  --
  per_asg_bus1.chk_assignment_status_type
  (p_assignment_status_type_id => l_assignment_status_type_id
  ,p_business_group_id         => l_business_group_id
  ,p_legislation_code          => l_legislation_code
  ,p_expected_system_status    => 'ACTIVE_ASSIGN'
  );
  --
  hr_utility.set_location(l_proc,240);
  --
  l_oversubscribed_vacancy_id :=null;
  --
  -- #2468916: Need to retrieve the period of service id
  open get_primary;
  fetch get_primary into l_primary_asg_id,l_primary_ovn, l_period_of_service_id;
  close get_primary;
  --
  for asg_rec in csr_get_accepted loop
    --
    hr_utility.set_location(l_proc,250);
      --
     if asg_rec.effective_start_date=l_hire_date then
      l_datetrack_update_mode:='CORRECTION';
    else
      l_datetrack_update_mode:='UPDATE';
    end if;
    --
    if asg_rec.assignment_id <> p_primary_assignment_id or p_overwrite_primary ='N' then
       --
      per_asg_upd.upd
     (p_assignment_id                => asg_rec.assignment_id,
      p_object_version_number        => asg_rec.object_version_number,
      p_effective_date               => l_hire_date,
      p_datetrack_mode               => l_datetrack_update_mode,
      p_assignment_status_type_id    => l_assignment_status_type_id,
      p_assignment_type              => 'E',
      p_primary_flag                 => 'N',
      p_period_of_service_id         => l_period_of_service_id,
      --
      p_effective_start_date         => l_effective_start_date,
      p_effective_end_date           => l_effective_end_date,
      p_business_group_id            => l_business_group_id,
      p_comment_id                   => l_comment_id,
      p_validation_start_date        => l_validation_start_date,
      p_validation_end_date          => l_validation_end_date,
      p_payroll_id_updated           => l_payroll_id_updated,
      p_other_manager_warning        => l_other_manager_warning,
      p_no_managers_warning          => l_no_managers_warning,
      p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
      p_hourly_salaried_warning      => l_hourly_salaried_warning
      );
      --
      hr_utility.set_location(l_proc,260);
--The below has been commented as part of bug fix 5481530
--      if asg_rec.assignment_id = p_primary_assignment_id then
      if asg_rec.assignment_id = l_primary_assignment_id then
        hr_assignment_api.set_new_primary_asg
        (p_validate              => false
        ,p_effective_date        => l_hire_date
        ,p_person_id             => p_person_id
        ,p_assignment_id         => asg_rec.assignment_id
        ,p_object_version_number => asg_rec.object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        );
      end if;
-- Bug 4644830 Start
       OPEN get_pay_proposal(asg_rec.assignment_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason for Bug # 5987409 --
       if get_pay_proposal%found then
          close get_pay_proposal;
          hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning           => l_approved_warning,
                        p_payroll_warning            => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

       else
          close get_pay_proposal;
       end if;
-- Bug 4644830 End
-- Bug 4630129 Starts
   elsif asg_rec.assignment_id = p_primary_assignment_id and p_overwrite_primary ='Y' then
-- Hire the new secondary Applicant assignment.
      hr_utility.set_location(l_proc,261);
      per_asg_upd.upd
     (p_assignment_id                => asg_rec.assignment_id,
      p_object_version_number        => asg_rec.object_version_number,
      p_effective_date               => l_hire_date,
      p_datetrack_mode               => l_datetrack_update_mode,
      p_assignment_status_type_id    => l_assignment_status_type_id,
      p_assignment_type              => 'E',
      p_primary_flag                 => 'N',
      p_period_of_service_id         => l_period_of_service_id,
      --
      p_effective_start_date         => l_effective_start_date,
      p_effective_end_date           => l_effective_end_date,
      p_business_group_id            => l_business_group_id,
      p_comment_id                   => l_comment_id,
      p_validation_start_date        => l_validation_start_date,
      p_validation_end_date          => l_validation_end_date,
      p_payroll_id_updated           => l_payroll_id_updated,
      p_other_manager_warning        => l_other_manager_warning,
      p_no_managers_warning          => l_no_managers_warning,
      p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
      p_hourly_salaried_warning      => l_hourly_salaried_warning
      );
-- Make the new secondary Applicant assignment Primary.
      hr_utility.set_location(l_proc,262);
      hr_assignment_api.set_new_primary_asg
      (p_validate              => false
      ,p_effective_date        => l_hire_date
      ,p_person_id             => p_person_id
      ,p_assignment_id         => asg_rec.assignment_id
      ,p_object_version_number => asg_rec.object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
        );
      hr_utility.set_location(l_proc,263);
-- Bug 4630129 Ends
-- Bug 4644830 Start
       OPEN get_pay_proposal(asg_rec.assignment_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason for Bug # 5987409 --
       if get_pay_proposal%found then
          close get_pay_proposal;
          hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning           => l_approved_warning,
                        p_payroll_warning            => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

       else
          close get_pay_proposal;
       end if;
-- Bug 4644830 End

 -- fix for the bug 4777901 starts here

 elsif  p_overwrite_primary ='W' then
 --
-- bug 5024006 fix  starts here
--
if l_check_loop=0 then

  open get_primary;
      fetch get_primary into l_primary_asg_id,l_primary_ovn,  l_period_of_service_id; -- #2468916
      close get_primary;
      --
      hr_utility.set_location(l_proc, 264);
      --
      open get_asg(asg_rec.assignment_id);
      fetch get_asg into l_asg_rec;
      close get_asg;

      ---changes for 4959033 starts here
      open get_primary_approved_proposal(l_primary_asg_id);
      fetch get_primary_approved_proposal into l_pay_pspl_id;

      if get_primary_approved_proposal%found then
      close get_primary_approved_proposal;

          if l_asg_rec.pay_basis_id  is null then
           hr_utility.set_message(800,'HR_289767_SALARY_BASIS_IS_NULL');
           hr_utility.raise_error;
          end if;
      --Added else to close the cursor--5277866
       else
      close get_primary_approved_proposal;
       end if;
      ---changes for 4959033 ends here

       if l_asg_rec.people_group_id is not null then
              --
              hr_utility.set_location(l_proc, 265);
              --
              open get_pgp(l_asg_rec.people_group_id);
              fetch get_pgp into l_pgp_rec;
              close get_pgp;

      end if;

      if l_asg_rec.soft_coding_keyflex_id is not null then
              --
              hr_utility.set_location(l_proc, 266);
              --
              open get_scl(l_asg_rec.soft_coding_keyflex_id);
              fetch get_scl into l_scl_rec;
              close get_scl;

	end if;
            --
            if l_asg_rec.cagr_grade_def_id is not null then
              --
              hr_utility.set_location(l_proc, 267);
              --
              open get_cag(l_asg_rec.cagr_grade_def_id);
              fetch get_cag into l_cag_rec;
              close get_cag;
             end if;
      --

      hr_utility.set_location(l_proc, 268);
      --

      --The below call has been commented as per bug 5102160
      -- soft_coding_keyflex_id is passed by calling the new update_emp_asg_criteria procedure

      /*hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_dummy
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      );*/

      hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_people_group_id              => l_dummy
      ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
      );

      --
      hr_utility.set_location(l_proc, 269);
      --
      hr_assignment_api.update_emp_asg
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_supervisor_id                => l_asg_rec.supervisor_id
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_date_probation_end           => l_asg_rec.date_probation_end
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_perf_review_period           => l_asg_rec.perf_review_period
      ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
      ,p_probation_period             => l_asg_rec.probation_period
      ,p_probation_unit               => l_asg_rec.probation_unit
      ,p_sal_review_period            => l_asg_rec.sal_review_period
      ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
      ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
      ,p_hourly_salaried_code         => l_asg_rec.hourly_salaried_code
      ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_ass_attribute1               => l_asg_rec.ass_attribute1
      ,p_ass_attribute2               => l_asg_rec.ass_attribute2
      ,p_ass_attribute3               => l_asg_rec.ass_attribute3
      ,p_ass_attribute4               => l_asg_rec.ass_attribute4
      ,p_ass_attribute5               => l_asg_rec.ass_attribute5
      ,p_ass_attribute6               => l_asg_rec.ass_attribute6
      ,p_ass_attribute7               => l_asg_rec.ass_attribute7
      ,p_ass_attribute8               => l_asg_rec.ass_attribute8
      ,p_ass_attribute9               => l_asg_rec.ass_attribute9
      ,p_ass_attribute10              => l_asg_rec.ass_attribute10
      ,p_ass_attribute11              => l_asg_rec.ass_attribute11
      ,p_ass_attribute12              => l_asg_rec.ass_attribute12
      ,p_ass_attribute13              => l_asg_rec.ass_attribute13
      ,p_ass_attribute14              => l_asg_rec.ass_attribute14
      ,p_ass_attribute15              => l_asg_rec.ass_attribute15
      ,p_ass_attribute16              => l_asg_rec.ass_attribute16
      ,p_ass_attribute17              => l_asg_rec.ass_attribute17
      ,p_ass_attribute18              => l_asg_rec.ass_attribute18
      ,p_ass_attribute19              => l_asg_rec.ass_attribute19
      ,p_ass_attribute20              => l_asg_rec.ass_attribute20
      ,p_ass_attribute21              => l_asg_rec.ass_attribute21
      ,p_ass_attribute22              => l_asg_rec.ass_attribute22
      ,p_ass_attribute23              => l_asg_rec.ass_attribute23
      ,p_ass_attribute24              => l_asg_rec.ass_attribute24
      ,p_ass_attribute25              => l_asg_rec.ass_attribute25
      ,p_ass_attribute26              => l_asg_rec.ass_attribute26
      ,p_ass_attribute27              => l_asg_rec.ass_attribute27
      ,p_ass_attribute28              => l_asg_rec.ass_attribute28
      ,p_ass_attribute29              => l_asg_rec.ass_attribute29
      ,p_ass_attribute30              => l_asg_rec.ass_attribute30
      ,p_segment1                     => l_scl_rec.segment1
      ,p_segment2                     => l_scl_rec.segment2
      ,p_segment3                     => l_scl_rec.segment3
      ,p_segment4                     => l_scl_rec.segment4
      ,p_segment5                     => l_scl_rec.segment5
      ,p_segment6                     => l_scl_rec.segment6
      ,p_segment7                     => l_scl_rec.segment7
      ,p_segment8                     => l_scl_rec.segment8
      ,p_segment9                     => l_scl_rec.segment9
      ,p_segment10                    => l_scl_rec.segment10
      ,p_segment11                    => l_scl_rec.segment11
      ,p_segment12                    => l_scl_rec.segment12
      ,p_segment13                    => l_scl_rec.segment13
      ,p_segment14                    => l_scl_rec.segment14
      ,p_segment15                    => l_scl_rec.segment15
      ,p_segment16                    => l_scl_rec.segment16
      ,p_segment17                    => l_scl_rec.segment17
      ,p_segment18                    => l_scl_rec.segment18
      ,p_segment19                    => l_scl_rec.segment19
      ,p_segment20                    => l_scl_rec.segment20
      ,p_segment21                    => l_scl_rec.segment21
      ,p_segment22                    => l_scl_rec.segment22
      ,p_segment23                    => l_scl_rec.segment23
      ,p_segment24                    => l_scl_rec.segment24
      ,p_segment25                    => l_scl_rec.segment25
      ,p_segment26                    => l_scl_rec.segment26
      ,p_segment27                    => l_scl_rec.segment27
      ,p_segment28                    => l_scl_rec.segment28
      ,p_segment29                    => l_scl_rec.segment29
      ,p_segment30                    => l_scl_rec.segment30
      ,p_contract_id                  => l_asg_rec.contract_id
      ,p_establishment_id             => l_asg_rec.establishment_id
      ,p_collective_agreement_id      => l_asg_rec.collective_agreement_id
      ,p_cagr_id_flex_num             => l_asg_rec.cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_rec.segment1
      ,p_cag_segment2                 => l_cag_rec.segment2
      ,p_cag_segment3                 => l_cag_rec.segment3
      ,p_cag_segment4                 => l_cag_rec.segment4
      ,p_cag_segment5                 => l_cag_rec.segment5
      ,p_cag_segment6                 => l_cag_rec.segment6
      ,p_cag_segment7                 => l_cag_rec.segment7
      ,p_cag_segment8                 => l_cag_rec.segment8
      ,p_cag_segment9                 => l_cag_rec.segment9
      ,p_cag_segment10                => l_cag_rec.segment10
      ,p_cag_segment11                => l_cag_rec.segment11
      ,p_cag_segment12                => l_cag_rec.segment12
      ,p_cag_segment13                => l_cag_rec.segment13
      ,p_cag_segment14                => l_cag_rec.segment14
      ,p_cag_segment15                => l_cag_rec.segment15
      ,p_cag_segment16                => l_cag_rec.segment16
      ,p_cag_segment17                => l_cag_rec.segment17
      ,p_cag_segment18                => l_cag_rec.segment18
      ,p_cag_segment19                => l_cag_rec.segment19
      ,p_cag_segment20                => l_cag_rec.segment20
      ,p_notice_period		      => l_asg_rec.notice_period
      ,p_notice_period_uom            => l_asg_rec.notice_period_uom
      ,p_employee_category            => l_asg_rec.employee_category
      ,p_work_at_home		      => l_asg_rec.work_at_home
      ,p_job_post_source_name	      => l_asg_rec.job_post_source_name
      ,p_cagr_grade_def_id            => l_dummynum1 -- Bug # 2788390 modified l_dummy to l_dummynum1.
      ,p_cagr_concatenated_segments   => l_dummyv
      ,p_concatenated_segments        => l_dummyv
      ,p_soft_coding_keyflex_id       => l_dummy1
      ,p_comment_id                   => l_dummy2
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_no_managers_warning          => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_hourly_salaried_warning      => l_dummyb
      );
      --
      hr_utility.set_location(l_proc, 271);

--Fix For Bug # 5987409 Starts -----

UPDATE PER_ASSIGNMENTS_F PAF SET PAF.VACANCY_ID =l_asg_rec.vacancy_id ,
PAF.RECRUITER_ID =l_asg_rec.recruiter_id
WHERE  PAF.ASSIGNMENT_ID = l_primary_asg_id AND
PAF.EFFECTIVE_START_DATE = l_effective_start_date AND
PAF.EFFECTIVE_END_DATE = l_effective_end_date;

--Fix For Bug # 5987409 Starts -----


      --
      -- now end date the application
      --
      per_asg_del.del
      (p_assignment_id              => l_asg_rec.assignment_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_business_group_id          => l_business_group_id
      ,p_object_version_number	    => l_asg_rec.object_version_number
      ,p_effective_date             => l_hire_date-1
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      ,p_datetrack_mode             => 'DELETE'
      ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
      --
      hr_utility.set_location(l_proc, 272);
      --
      --

       l_pspl_asg_id :=asg_rec.assignment_id;


       OPEN get_pay_proposal(l_pspl_asg_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; -- Added Proposal_Reason For Bug # 5987409 --
       if get_pay_proposal%found then
             l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
            open get_primary_proposal(l_primary_asg_id);
            fetch get_primary_proposal into l_pay_pspl_id,l_pay_obj_number;
              if get_primary_proposal%found then
                 close get_primary_proposal;
                 hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
             	        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);
             else
	     close get_primary_proposal;
	     l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id,
                        p_assignment_id              => l_primary_asg_id,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

             end if;
	--
      end if;
     --
        close get_pay_proposal;
     --
   l_check_loop := l_check_loop +1;

 end if;

     -- fix for the bug 5024006 ends here

    else
      --
      hr_utility.set_location(l_proc, 270);
      --
      -- we must update the old assignment with the new assignment record
      --
      open get_primary;
      fetch get_primary into l_primary_asg_id,l_primary_ovn,  l_period_of_service_id; -- #2468916
      close get_primary;
      --
      hr_utility.set_location(l_proc, 280);
      --
      open get_asg(asg_rec.assignment_id);
      fetch get_asg into l_asg_rec;
      close get_asg;
      --
      hr_utility.set_location(l_proc, 290);
      --
      if l_asg_rec.people_group_id is not null then
        --
        hr_utility.set_location(l_proc, 300);
        --
        open get_pgp(l_asg_rec.people_group_id);
        fetch get_pgp into l_pgp_rec;
        close get_pgp;
      end if;
      --
      if l_asg_rec.soft_coding_keyflex_id is not null then
        --
        hr_utility.set_location(l_proc, 310);
        --
        open get_scl(l_asg_rec.soft_coding_keyflex_id);
        fetch get_scl into l_scl_rec;
        close get_scl;
      end if;
      --
      if l_asg_rec.cagr_grade_def_id is not null then
        --
        hr_utility.set_location(l_proc, 320);
        --
        open get_cag(l_asg_rec.cagr_grade_def_id);
        fetch get_cag into l_cag_rec;
        close get_cag;
      end if;
      --
      hr_utility.set_location(l_proc, 330);
      --
      if p_overwrite_primary = 'V' then
        --
        open get_asg(l_primary_asg_id);
        fetch get_asg into l_primary_asg_rec;
        close get_asg;
        --
        if l_primary_asg_rec.people_group_id is not null then
          open get_pgp(l_primary_asg_rec.people_group_id);
          fetch get_pgp into l_primary_pgp_rec;
          close get_pgp;
        end if;
        --
        if l_primary_asg_rec.soft_coding_keyflex_id is not null then
          open get_scl(l_primary_asg_rec.soft_coding_keyflex_id);
          fetch get_scl into l_primary_scl_rec;
          close get_scl;
        end if;
        --
        if l_primary_asg_rec.cagr_grade_def_id is not null then
          open get_cag(l_primary_asg_rec.cagr_grade_def_id);
          fetch get_cag into l_primary_cag_rec;
          close get_cag;
        end if;
        --
        -- Merge new and old primary assignments, giving preference to the
        -- new one.
        --
	--Bug 4234518
	--
	 l_asg_rec.employee_category :=  NVL(l_asg_rec.employee_category,l_primary_asg_rec.employee_category);
	 --Bug fix 4234518 ends here
	 --
        l_asg_rec.employment_category := NVL(l_asg_rec.employment_category,l_primary_asg_rec.employment_category);
        l_asg_rec.grade_id := NVL(l_asg_rec.grade_id,l_primary_asg_rec.grade_id);
        l_asg_rec.job_id := NVL(l_asg_rec.job_id,l_primary_asg_rec.job_id);
        l_asg_rec.location_id := NVL(l_asg_rec.location_id,l_primary_asg_rec.location_id);
        l_asg_rec.organization_id := NVL(l_asg_rec.organization_id,l_primary_asg_rec.organization_id);
        l_asg_rec.payroll_id := NVL(l_asg_rec.payroll_id,l_primary_asg_rec.payroll_id);
        l_asg_rec.pay_basis_id := NVL(l_asg_rec.pay_basis_id,l_primary_asg_rec.pay_basis_id);
        l_asg_rec.position_id := NVL(l_asg_rec.position_id,l_primary_asg_rec.position_id);
        l_asg_rec.special_ceiling_step_id := NVL(l_asg_rec.special_ceiling_step_id,l_primary_asg_rec.special_ceiling_step_id);
        --
        l_pgp_rec.segment1  := NVL(l_pgp_rec.segment1, l_primary_pgp_rec.segment1);
        l_pgp_rec.segment2  := NVL(l_pgp_rec.segment2, l_primary_pgp_rec.segment2);
        l_pgp_rec.segment3  := NVL(l_pgp_rec.segment3, l_primary_pgp_rec.segment3);
        l_pgp_rec.segment4  := NVL(l_pgp_rec.segment4, l_primary_pgp_rec.segment4);
        l_pgp_rec.segment5  := NVL(l_pgp_rec.segment5, l_primary_pgp_rec.segment5);
        l_pgp_rec.segment6  := NVL(l_pgp_rec.segment6, l_primary_pgp_rec.segment6);
        l_pgp_rec.segment7  := NVL(l_pgp_rec.segment7, l_primary_pgp_rec.segment7);
        l_pgp_rec.segment8  := NVL(l_pgp_rec.segment8, l_primary_pgp_rec.segment8);    --- Fix For Bug # 8758419
        l_pgp_rec.segment9  := NVL(l_pgp_rec.segment9, l_primary_pgp_rec.segment9);
        l_pgp_rec.segment10 := NVL(l_pgp_rec.segment10,l_primary_pgp_rec.segment10);
        l_pgp_rec.segment11 := NVL(l_pgp_rec.segment11,l_primary_pgp_rec.segment11);
        l_pgp_rec.segment12 := NVL(l_pgp_rec.segment12,l_primary_pgp_rec.segment12);
        l_pgp_rec.segment13 := NVL(l_pgp_rec.segment13,l_primary_pgp_rec.segment13);
        l_pgp_rec.segment14 := NVL(l_pgp_rec.segment14,l_primary_pgp_rec.segment14);
        l_pgp_rec.segment15 := NVL(l_pgp_rec.segment15,l_primary_pgp_rec.segment15);
        l_pgp_rec.segment16 := NVL(l_pgp_rec.segment16,l_primary_pgp_rec.segment16);
        l_pgp_rec.segment17 := NVL(l_pgp_rec.segment17,l_primary_pgp_rec.segment17);
        l_pgp_rec.segment18 := NVL(l_pgp_rec.segment18,l_primary_pgp_rec.segment18);
        l_pgp_rec.segment19 := NVL(l_pgp_rec.segment19,l_primary_pgp_rec.segment19);
        l_pgp_rec.segment20 := NVL(l_pgp_rec.segment20,l_primary_pgp_rec.segment20);
        l_pgp_rec.segment21 := NVL(l_pgp_rec.segment21,l_primary_pgp_rec.segment21);
        l_pgp_rec.segment22 := NVL(l_pgp_rec.segment22,l_primary_pgp_rec.segment22);
        l_pgp_rec.segment23 := NVL(l_pgp_rec.segment23,l_primary_pgp_rec.segment23);
        l_pgp_rec.segment24 := NVL(l_pgp_rec.segment24,l_primary_pgp_rec.segment24);
        l_pgp_rec.segment25 := NVL(l_pgp_rec.segment25,l_primary_pgp_rec.segment25);
        l_pgp_rec.segment26 := NVL(l_pgp_rec.segment26,l_primary_pgp_rec.segment26);
        l_pgp_rec.segment27 := NVL(l_pgp_rec.segment27,l_primary_pgp_rec.segment27);
        l_pgp_rec.segment28 := NVL(l_pgp_rec.segment28,l_primary_pgp_rec.segment28);
        l_pgp_rec.segment29 := NVL(l_pgp_rec.segment29,l_primary_pgp_rec.segment29);
        l_pgp_rec.segment30 := NVL(l_pgp_rec.segment30,l_primary_pgp_rec.segment30);
        --
--        l_asg_rec.assignment_number := NVL(l_asg_rec.assignment_number,l_primary_asg_rec.assignment_number);
        l_asg_rec.bargaining_unit_code := NVL(l_asg_rec.bargaining_unit_code,l_primary_asg_rec.bargaining_unit_code);
--        l_asg_rec.change_reason := NVL(l_asg_rec.change_reason,l_primary_asg_rec.change_reason);
        l_asg_rec.collective_agreement_id := NVL(l_asg_rec.collective_agreement_id,l_primary_asg_rec.collective_agreement_id);
        l_asg_rec.contract_id := NVL(l_asg_rec.contract_id,l_primary_asg_rec.contract_id);
        l_asg_rec.date_probation_end := NVL(l_asg_rec.date_probation_end,l_primary_asg_rec.date_probation_end);
        l_asg_rec.default_code_comb_id := NVL(l_asg_rec.default_code_comb_id,l_primary_asg_rec.default_code_comb_id);
        l_asg_rec.establishment_id := NVL(l_asg_rec.establishment_id,l_primary_asg_rec.establishment_id);
        l_asg_rec.frequency := NVL(l_asg_rec.frequency,l_primary_asg_rec.frequency);
        l_asg_rec.hourly_salaried_code := NVL(l_asg_rec.hourly_salaried_code,l_primary_asg_rec.hourly_salaried_code);
        l_asg_rec.internal_address_line := NVL(l_asg_rec.internal_address_line,l_primary_asg_rec.internal_address_line);
        l_asg_rec.labour_union_member_flag := NVL(l_asg_rec.labour_union_member_flag,l_primary_asg_rec.labour_union_member_flag);
        l_asg_rec.manager_flag := NVL(l_asg_rec.manager_flag,l_primary_asg_rec.manager_flag);
        l_asg_rec.normal_hours := NVL(l_asg_rec.normal_hours,l_primary_asg_rec.normal_hours);
        l_asg_rec.perf_review_period := NVL(l_asg_rec.perf_review_period,l_primary_asg_rec.perf_review_period);
        l_asg_rec.perf_review_period_frequency := NVL(l_asg_rec.perf_review_period_frequency,l_primary_asg_rec.perf_review_period_frequency);
        l_asg_rec.probation_period := NVL(l_asg_rec.probation_period,l_primary_asg_rec.probation_period);
        l_asg_rec.probation_unit := NVL(l_asg_rec.probation_unit,l_primary_asg_rec.probation_unit);
        l_asg_rec.sal_review_period := NVL(l_asg_rec.sal_review_period,l_primary_asg_rec.sal_review_period);
        l_asg_rec.sal_review_period_frequency := NVL(l_asg_rec.sal_review_period_frequency,l_primary_asg_rec.sal_review_period_frequency);
        l_asg_rec.set_of_books_id := NVL(l_asg_rec.set_of_books_id,l_primary_asg_rec.set_of_books_id);
        l_asg_rec.source_type := NVL(l_asg_rec.source_type,l_primary_asg_rec.source_type);
        l_asg_rec.supervisor_id := NVL(l_asg_rec.supervisor_id,l_primary_asg_rec.supervisor_id);
        l_asg_rec.time_normal_finish := NVL(l_asg_rec.time_normal_finish,l_primary_asg_rec.time_normal_finish);
        l_asg_rec.time_normal_start := NVL(l_asg_rec.time_normal_start,l_primary_asg_rec.time_normal_start);
        --
        if (l_asg_rec.ass_attribute_category = l_primary_asg_rec.ass_attribute_category) then
          l_asg_rec.ass_attribute1  := NVL(l_asg_rec.ass_attribute1, l_primary_asg_rec.ass_attribute1);
          l_asg_rec.ass_attribute2  := NVL(l_asg_rec.ass_attribute2, l_primary_asg_rec.ass_attribute2);
          l_asg_rec.ass_attribute3  := NVL(l_asg_rec.ass_attribute3, l_primary_asg_rec.ass_attribute3);
          l_asg_rec.ass_attribute4  := NVL(l_asg_rec.ass_attribute4, l_primary_asg_rec.ass_attribute4);
          l_asg_rec.ass_attribute5  := NVL(l_asg_rec.ass_attribute5, l_primary_asg_rec.ass_attribute5);
          l_asg_rec.ass_attribute6  := NVL(l_asg_rec.ass_attribute6, l_primary_asg_rec.ass_attribute6);
          l_asg_rec.ass_attribute7  := NVL(l_asg_rec.ass_attribute7, l_primary_asg_rec.ass_attribute7);
          l_asg_rec.ass_attribute8  := NVL(l_asg_rec.ass_attribute8, l_primary_asg_rec.ass_attribute8);
          l_asg_rec.ass_attribute9  := NVL(l_asg_rec.ass_attribute9, l_primary_asg_rec.ass_attribute9);
          l_asg_rec.ass_attribute10 := NVL(l_asg_rec.ass_attribute10,l_primary_asg_rec.ass_attribute10);
          l_asg_rec.ass_attribute11 := NVL(l_asg_rec.ass_attribute11,l_primary_asg_rec.ass_attribute11);
          l_asg_rec.ass_attribute12 := NVL(l_asg_rec.ass_attribute12,l_primary_asg_rec.ass_attribute12);
          l_asg_rec.ass_attribute13 := NVL(l_asg_rec.ass_attribute13,l_primary_asg_rec.ass_attribute13);
          l_asg_rec.ass_attribute14 := NVL(l_asg_rec.ass_attribute14,l_primary_asg_rec.ass_attribute14);
          l_asg_rec.ass_attribute15 := NVL(l_asg_rec.ass_attribute15,l_primary_asg_rec.ass_attribute15);
          l_asg_rec.ass_attribute16 := NVL(l_asg_rec.ass_attribute16,l_primary_asg_rec.ass_attribute16);
          l_asg_rec.ass_attribute17 := NVL(l_asg_rec.ass_attribute17,l_primary_asg_rec.ass_attribute17);
          l_asg_rec.ass_attribute18 := NVL(l_asg_rec.ass_attribute18,l_primary_asg_rec.ass_attribute18);
          l_asg_rec.ass_attribute19 := NVL(l_asg_rec.ass_attribute19,l_primary_asg_rec.ass_attribute19);
          l_asg_rec.ass_attribute20 := NVL(l_asg_rec.ass_attribute20,l_primary_asg_rec.ass_attribute20);
          l_asg_rec.ass_attribute21 := NVL(l_asg_rec.ass_attribute21,l_primary_asg_rec.ass_attribute21);
          l_asg_rec.ass_attribute22 := NVL(l_asg_rec.ass_attribute22,l_primary_asg_rec.ass_attribute22);
          l_asg_rec.ass_attribute23 := NVL(l_asg_rec.ass_attribute23,l_primary_asg_rec.ass_attribute23);
          l_asg_rec.ass_attribute24 := NVL(l_asg_rec.ass_attribute24,l_primary_asg_rec.ass_attribute24);
          l_asg_rec.ass_attribute25 := NVL(l_asg_rec.ass_attribute25,l_primary_asg_rec.ass_attribute25);
          l_asg_rec.ass_attribute26 := NVL(l_asg_rec.ass_attribute26,l_primary_asg_rec.ass_attribute26);
          l_asg_rec.ass_attribute27 := NVL(l_asg_rec.ass_attribute27,l_primary_asg_rec.ass_attribute27);
          l_asg_rec.ass_attribute28 := NVL(l_asg_rec.ass_attribute28,l_primary_asg_rec.ass_attribute28);
          l_asg_rec.ass_attribute29 := NVL(l_asg_rec.ass_attribute29,l_primary_asg_rec.ass_attribute29);
          l_asg_rec.ass_attribute30 := NVL(l_asg_rec.ass_attribute30,l_primary_asg_rec.ass_attribute30);
        elsif (l_asg_rec.ass_attribute_category is null) then
          l_asg_rec.ass_attribute_category := l_primary_asg_rec.ass_attribute_category;
          l_asg_rec.ass_attribute1  := l_primary_asg_rec.ass_attribute1;
          l_asg_rec.ass_attribute2  := l_primary_asg_rec.ass_attribute2;
          l_asg_rec.ass_attribute3  := l_primary_asg_rec.ass_attribute3;
          l_asg_rec.ass_attribute4  := l_primary_asg_rec.ass_attribute4;
          l_asg_rec.ass_attribute5  := l_primary_asg_rec.ass_attribute5;
          l_asg_rec.ass_attribute6  := l_primary_asg_rec.ass_attribute6;
          l_asg_rec.ass_attribute7  := l_primary_asg_rec.ass_attribute7;
          l_asg_rec.ass_attribute8  := l_primary_asg_rec.ass_attribute8;
          l_asg_rec.ass_attribute9  := l_primary_asg_rec.ass_attribute9;
          l_asg_rec.ass_attribute10 := l_primary_asg_rec.ass_attribute10;
          l_asg_rec.ass_attribute11 := l_primary_asg_rec.ass_attribute11;
          l_asg_rec.ass_attribute12 := l_primary_asg_rec.ass_attribute12;
          l_asg_rec.ass_attribute13 := l_primary_asg_rec.ass_attribute13;
          l_asg_rec.ass_attribute14 := l_primary_asg_rec.ass_attribute14;
          l_asg_rec.ass_attribute15 := l_primary_asg_rec.ass_attribute15;
          l_asg_rec.ass_attribute16 := l_primary_asg_rec.ass_attribute16;
          l_asg_rec.ass_attribute17 := l_primary_asg_rec.ass_attribute17;
          l_asg_rec.ass_attribute18 := l_primary_asg_rec.ass_attribute18;
          l_asg_rec.ass_attribute19 := l_primary_asg_rec.ass_attribute19;
          l_asg_rec.ass_attribute20 := l_primary_asg_rec.ass_attribute20;
          l_asg_rec.ass_attribute21 := l_primary_asg_rec.ass_attribute21;
          l_asg_rec.ass_attribute22 := l_primary_asg_rec.ass_attribute22;
          l_asg_rec.ass_attribute23 := l_primary_asg_rec.ass_attribute23;
          l_asg_rec.ass_attribute24 := l_primary_asg_rec.ass_attribute24;
          l_asg_rec.ass_attribute25 := l_primary_asg_rec.ass_attribute25;
          l_asg_rec.ass_attribute26 := l_primary_asg_rec.ass_attribute26;
          l_asg_rec.ass_attribute27 := l_primary_asg_rec.ass_attribute27;
          l_asg_rec.ass_attribute28 := l_primary_asg_rec.ass_attribute28;
          l_asg_rec.ass_attribute29 := l_primary_asg_rec.ass_attribute29;
          l_asg_rec.ass_attribute30 := l_primary_asg_rec.ass_attribute30;
        end if;
        --
        if (l_asg_rec.cagr_id_flex_num = l_primary_asg_rec.cagr_id_flex_num) then
          l_cag_rec.segment1  := NVL(l_cag_rec.segment1, l_primary_cag_rec.segment1);
          l_cag_rec.segment2  := NVL(l_cag_rec.segment2, l_primary_cag_rec.segment2);
          l_cag_rec.segment3  := NVL(l_cag_rec.segment3, l_primary_cag_rec.segment3);
          l_cag_rec.segment4  := NVL(l_cag_rec.segment4, l_primary_cag_rec.segment4);
          l_cag_rec.segment5  := NVL(l_cag_rec.segment5, l_primary_cag_rec.segment5);
          l_cag_rec.segment6  := NVL(l_cag_rec.segment6, l_primary_cag_rec.segment6);
          l_cag_rec.segment7  := NVL(l_cag_rec.segment7, l_primary_cag_rec.segment7);
          l_cag_rec.segment8  := NVL(l_cag_rec.segment8, l_primary_cag_rec.segment8);
          l_cag_rec.segment9  := NVL(l_cag_rec.segment9, l_primary_cag_rec.segment9);
          l_cag_rec.segment10 := NVL(l_cag_rec.segment10,l_primary_cag_rec.segment10);
          l_cag_rec.segment11 := NVL(l_cag_rec.segment11,l_primary_cag_rec.segment11);
          l_cag_rec.segment12 := NVL(l_cag_rec.segment12,l_primary_cag_rec.segment12);
          l_cag_rec.segment13 := NVL(l_cag_rec.segment13,l_primary_cag_rec.segment13);
          l_cag_rec.segment14 := NVL(l_cag_rec.segment14,l_primary_cag_rec.segment14);
          l_cag_rec.segment15 := NVL(l_cag_rec.segment15,l_primary_cag_rec.segment15);
          l_cag_rec.segment16 := NVL(l_cag_rec.segment16,l_primary_cag_rec.segment16);
          l_cag_rec.segment17 := NVL(l_cag_rec.segment17,l_primary_cag_rec.segment17);
          l_cag_rec.segment18 := NVL(l_cag_rec.segment18,l_primary_cag_rec.segment18);
          l_cag_rec.segment19 := NVL(l_cag_rec.segment19,l_primary_cag_rec.segment19);
          l_cag_rec.segment20 := NVL(l_cag_rec.segment20,l_primary_cag_rec.segment20);
       elsif (l_asg_rec.cagr_id_flex_num is null) then
          l_asg_rec.cagr_id_flex_num := l_primary_asg_rec.cagr_id_flex_num;
          l_cag_rec.segment1  := l_primary_cag_rec.segment1;
          l_cag_rec.segment2  := l_primary_cag_rec.segment2;
          l_cag_rec.segment3  := l_primary_cag_rec.segment3;
          l_cag_rec.segment4  := l_primary_cag_rec.segment4;
          l_cag_rec.segment5  := l_primary_cag_rec.segment5;
          l_cag_rec.segment6  := l_primary_cag_rec.segment6;
          l_cag_rec.segment7  := l_primary_cag_rec.segment7;
          l_cag_rec.segment8  := l_primary_cag_rec.segment8;
          l_cag_rec.segment9  := l_primary_cag_rec.segment9;
          l_cag_rec.segment10 := l_primary_cag_rec.segment10;
          l_cag_rec.segment11 := l_primary_cag_rec.segment11;
          l_cag_rec.segment12 := l_primary_cag_rec.segment12;
          l_cag_rec.segment13 := l_primary_cag_rec.segment13;
          l_cag_rec.segment14 := l_primary_cag_rec.segment14;
          l_cag_rec.segment15 := l_primary_cag_rec.segment15;
          l_cag_rec.segment16 := l_primary_cag_rec.segment16;
          l_cag_rec.segment17 := l_primary_cag_rec.segment17;
          l_cag_rec.segment18 := l_primary_cag_rec.segment18;
          l_cag_rec.segment19 := l_primary_cag_rec.segment19;
          l_cag_rec.segment20 := l_primary_cag_rec.segment20;
        end if;
        --
        l_scl_rec.segment1  := NVL(l_scl_rec.segment1, l_primary_scl_rec.segment1);
        l_scl_rec.segment2  := NVL(l_scl_rec.segment2, l_primary_scl_rec.segment2);
        l_scl_rec.segment3  := NVL(l_scl_rec.segment3, l_primary_scl_rec.segment3);
        l_scl_rec.segment4  := NVL(l_scl_rec.segment4, l_primary_scl_rec.segment4);
        l_scl_rec.segment5  := NVL(l_scl_rec.segment5, l_primary_scl_rec.segment5);
        l_scl_rec.segment6  := NVL(l_scl_rec.segment6, l_primary_scl_rec.segment6);
        l_scl_rec.segment7  := NVL(l_scl_rec.segment7, l_primary_scl_rec.segment7);
        l_scl_rec.segment8  := NVL(l_scl_rec.segment8, l_primary_scl_rec.segment8);
        l_scl_rec.segment9  := NVL(l_scl_rec.segment9, l_primary_scl_rec.segment9);
        l_scl_rec.segment10 := NVL(l_scl_rec.segment10,l_primary_scl_rec.segment10);
        l_scl_rec.segment11 := NVL(l_scl_rec.segment11,l_primary_scl_rec.segment11);
        l_scl_rec.segment12 := NVL(l_scl_rec.segment12,l_primary_scl_rec.segment12);
        l_scl_rec.segment13 := NVL(l_scl_rec.segment13,l_primary_scl_rec.segment13);
        l_scl_rec.segment14 := NVL(l_scl_rec.segment14,l_primary_scl_rec.segment14);
        l_scl_rec.segment15 := NVL(l_scl_rec.segment15,l_primary_scl_rec.segment15);
        l_scl_rec.segment16 := NVL(l_scl_rec.segment16,l_primary_scl_rec.segment16);
        l_scl_rec.segment17 := NVL(l_scl_rec.segment17,l_primary_scl_rec.segment17);
        l_scl_rec.segment18 := NVL(l_scl_rec.segment18,l_primary_scl_rec.segment18);
        l_scl_rec.segment19 := NVL(l_scl_rec.segment19,l_primary_scl_rec.segment19);
        l_scl_rec.segment20 := NVL(l_scl_rec.segment20,l_primary_scl_rec.segment20);
        l_scl_rec.segment21 := NVL(l_scl_rec.segment21,l_primary_scl_rec.segment21);
        l_scl_rec.segment22 := NVL(l_scl_rec.segment22,l_primary_scl_rec.segment22);
        l_scl_rec.segment23 := NVL(l_scl_rec.segment23,l_primary_scl_rec.segment23);
        l_scl_rec.segment24 := NVL(l_scl_rec.segment24,l_primary_scl_rec.segment24);
        l_scl_rec.segment25 := NVL(l_scl_rec.segment25,l_primary_scl_rec.segment25);
        l_scl_rec.segment26 := NVL(l_scl_rec.segment26,l_primary_scl_rec.segment26);
        l_scl_rec.segment27 := NVL(l_scl_rec.segment27,l_primary_scl_rec.segment27);
        l_scl_rec.segment28 := NVL(l_scl_rec.segment28,l_primary_scl_rec.segment28);
        l_scl_rec.segment29 := NVL(l_scl_rec.segment29,l_primary_scl_rec.segment29);
        l_scl_rec.segment30 := NVL(l_scl_rec.segment30,l_primary_scl_rec.segment30);
        --
      end if;
      --
       --The below call to the old update_emp_asg_criteria procedure has been commented as per bug 5102160
      -- soft_coding_keyflex_id is passed by calling the new update_emp_asg_criteria procedure

     /* hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_dummy
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      );*/

      hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_people_group_id              => l_dummy
      ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
      );
      --
      hr_utility.set_location(l_proc, 340);
      --
      hr_assignment_api.update_emp_asg
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_supervisor_id                => l_asg_rec.supervisor_id
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_date_probation_end           => l_asg_rec.date_probation_end
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_perf_review_period           => l_asg_rec.perf_review_period
      ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
      ,p_probation_period             => l_asg_rec.probation_period
      ,p_probation_unit               => l_asg_rec.probation_unit
      ,p_sal_review_period            => l_asg_rec.sal_review_period
      ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
      ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
      ,p_hourly_salaried_code         => l_asg_rec.hourly_salaried_code
      ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_ass_attribute1               => l_asg_rec.ass_attribute1
      ,p_ass_attribute2               => l_asg_rec.ass_attribute2
      ,p_ass_attribute3               => l_asg_rec.ass_attribute3
      ,p_ass_attribute4               => l_asg_rec.ass_attribute4
      ,p_ass_attribute5               => l_asg_rec.ass_attribute5
      ,p_ass_attribute6               => l_asg_rec.ass_attribute6
      ,p_ass_attribute7               => l_asg_rec.ass_attribute7
      ,p_ass_attribute8               => l_asg_rec.ass_attribute8
      ,p_ass_attribute9               => l_asg_rec.ass_attribute9
      ,p_ass_attribute10              => l_asg_rec.ass_attribute10
      ,p_ass_attribute11              => l_asg_rec.ass_attribute11
      ,p_ass_attribute12              => l_asg_rec.ass_attribute12
      ,p_ass_attribute13              => l_asg_rec.ass_attribute13
      ,p_ass_attribute14              => l_asg_rec.ass_attribute14
      ,p_ass_attribute15              => l_asg_rec.ass_attribute15
      ,p_ass_attribute16              => l_asg_rec.ass_attribute16
      ,p_ass_attribute17              => l_asg_rec.ass_attribute17
      ,p_ass_attribute18              => l_asg_rec.ass_attribute18
      ,p_ass_attribute19              => l_asg_rec.ass_attribute19
      ,p_ass_attribute20              => l_asg_rec.ass_attribute20
      ,p_ass_attribute21              => l_asg_rec.ass_attribute21
      ,p_ass_attribute22              => l_asg_rec.ass_attribute22
      ,p_ass_attribute23              => l_asg_rec.ass_attribute23
      ,p_ass_attribute24              => l_asg_rec.ass_attribute24
      ,p_ass_attribute25              => l_asg_rec.ass_attribute25
      ,p_ass_attribute26              => l_asg_rec.ass_attribute26
      ,p_ass_attribute27              => l_asg_rec.ass_attribute27
      ,p_ass_attribute28              => l_asg_rec.ass_attribute28
      ,p_ass_attribute29              => l_asg_rec.ass_attribute29
      ,p_ass_attribute30              => l_asg_rec.ass_attribute30
      ,p_segment1                     => l_scl_rec.segment1
      ,p_segment2                     => l_scl_rec.segment2
      ,p_segment3                     => l_scl_rec.segment3
      ,p_segment4                     => l_scl_rec.segment4
      ,p_segment5                     => l_scl_rec.segment5
      ,p_segment6                     => l_scl_rec.segment6
      ,p_segment7                     => l_scl_rec.segment7
      ,p_segment8                     => l_scl_rec.segment8
      ,p_segment9                     => l_scl_rec.segment9
      ,p_segment10                    => l_scl_rec.segment10
      ,p_segment11                    => l_scl_rec.segment11
      ,p_segment12                    => l_scl_rec.segment12
      ,p_segment13                    => l_scl_rec.segment13
      ,p_segment14                    => l_scl_rec.segment14
      ,p_segment15                    => l_scl_rec.segment15
      ,p_segment16                    => l_scl_rec.segment16
      ,p_segment17                    => l_scl_rec.segment17
      ,p_segment18                    => l_scl_rec.segment18
      ,p_segment19                    => l_scl_rec.segment19
      ,p_segment20                    => l_scl_rec.segment20
      ,p_segment21                    => l_scl_rec.segment21
      ,p_segment22                    => l_scl_rec.segment22
      ,p_segment23                    => l_scl_rec.segment23
      ,p_segment24                    => l_scl_rec.segment24
      ,p_segment25                    => l_scl_rec.segment25
      ,p_segment26                    => l_scl_rec.segment26
      ,p_segment27                    => l_scl_rec.segment27
      ,p_segment28                    => l_scl_rec.segment28
      ,p_segment29                    => l_scl_rec.segment29
      ,p_segment30                    => l_scl_rec.segment30
      ,p_contract_id                  => l_asg_rec.contract_id
      ,p_establishment_id             => l_asg_rec.establishment_id
      ,p_collective_agreement_id      => l_asg_rec.collective_agreement_id
      ,p_cagr_id_flex_num             => l_asg_rec.cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_rec.segment1
      ,p_cag_segment2                 => l_cag_rec.segment2
      ,p_cag_segment3                 => l_cag_rec.segment3
      ,p_cag_segment4                 => l_cag_rec.segment4
      ,p_cag_segment5                 => l_cag_rec.segment5
      ,p_cag_segment6                 => l_cag_rec.segment6
      ,p_cag_segment7                 => l_cag_rec.segment7
      ,p_cag_segment8                 => l_cag_rec.segment8
      ,p_cag_segment9                 => l_cag_rec.segment9
      ,p_cag_segment10                => l_cag_rec.segment10
      ,p_cag_segment11                => l_cag_rec.segment11
      ,p_cag_segment12                => l_cag_rec.segment12
      ,p_cag_segment13                => l_cag_rec.segment13
      ,p_cag_segment14                => l_cag_rec.segment14
      ,p_cag_segment15                => l_cag_rec.segment15
      ,p_cag_segment16                => l_cag_rec.segment16
      ,p_cag_segment17                => l_cag_rec.segment17
      ,p_cag_segment18                => l_cag_rec.segment18
      ,p_cag_segment19                => l_cag_rec.segment19
      ,p_cag_segment20                => l_cag_rec.segment20
      ,p_notice_period		      => l_asg_rec.notice_period
      ,p_notice_period_uom            => l_asg_rec.notice_period_uom
      ,p_employee_category            => l_asg_rec.employee_category
      ,p_work_at_home		      => l_asg_rec.work_at_home
      ,p_job_post_source_name	      => l_asg_rec.job_post_source_name
      ,p_cagr_grade_def_id            => l_dummynum1 -- Bug # 2788390 modified l_dummy to l_dummynum1.
      ,p_cagr_concatenated_segments   => l_dummyv
      ,p_concatenated_segments        => l_dummyv
      ,p_soft_coding_keyflex_id       => l_dummy1
      ,p_comment_id                   => l_dummy2
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_no_managers_warning          => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_hourly_salaried_warning      => l_dummyb
      );
      --
      hr_utility.set_location(l_proc, 350);


--Fix For Bug # 5987409 Starts -----

UPDATE PER_ASSIGNMENTS_F PAF SET PAF.VACANCY_ID =l_asg_rec.vacancy_id ,
PAF.RECRUITER_ID =l_asg_rec.recruiter_id
WHERE  PAF.ASSIGNMENT_ID = l_primary_asg_id AND
PAF.EFFECTIVE_START_DATE = l_effective_start_date AND
PAF.EFFECTIVE_END_DATE = l_effective_end_date;

--Fix For Bug # 5987409 Starts -----


      --
      -- now end date the application
      --
      per_asg_del.del
      (p_assignment_id              => l_asg_rec.assignment_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_business_group_id          => l_business_group_id
      ,p_object_version_number	    => l_asg_rec.object_version_number
      ,p_effective_date             => l_hire_date-1
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      ,p_datetrack_mode             => 'DELETE'
      ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
      --
      hr_utility.set_location(l_proc, 360);
      --
       -- added for the bug 4641965
      --
       if (p_primary_assignment_id is not null ) then
       l_pspl_asg_id :=p_primary_assignment_id;
       else
       l_pspl_asg_id :=asg_rec.assignment_id;
       end if;
        --start of bug 5102289
	 open get_primary_pay_basis(l_primary_asg_id);
         fetch get_primary_pay_basis into l_pay_basis_id;
         if l_pay_basis_id = l_asg_rec.pay_basis_id then
           l_approved := 'N';
         else
           l_approved := 'Y';
         end if;
         close get_primary_pay_basis;
  	--End of bug 5102289

       OPEN get_pay_proposal(l_pspl_asg_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason For Bug # 5987409 --
       if get_pay_proposal%found then
             l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
            open get_primary_proposal (l_primary_asg_id);
            fetch get_primary_proposal into l_pay_pspl_id,l_pay_obj_number;
              if get_primary_proposal%found then
                 close get_primary_proposal;
                 hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
             	        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => l_approved,
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);
             else
	     close get_primary_proposal;
	     l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id,
                        p_assignment_id              => l_primary_asg_id,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => l_approved,
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

             end if;
	--
      end if;
     --
        close get_pay_proposal;
     --
     -- end of bug 4641965
    end if;
    --
--Bug 4959033

   open get_business_group(l_primary_asg_id);
   fetch get_business_group into l_bg_id;
  --
   if get_business_group%NOTFOUND then
      close get_business_group;
      l_bg_id := hr_general.get_business_group_id;
   else
      close get_business_group;
   end if;
   --
    hrentmnt.maintain_entries_asg (
    p_assignment_id         => l_primary_asg_id,
    p_business_group_id     => l_bg_id,
    p_operation             => 'ASG_CRITERIA',
    p_actual_term_date      => null,
    p_last_standard_date    => null,
    p_final_process_date    => null,
    p_dt_mode               => 'UPDATE',
    p_validation_start_date => l_effective_start_date,
    p_validation_end_date   => l_effective_end_date
   );
   -- End of Bug 4959033
    open csr_vacs(l_asg_rec.vacancy_id);
    fetch csr_vacs into l_dummy;
    if csr_vacs%found then
      close csr_vacs;
      l_oversubscribed_vacancy_id :=l_asg_rec.vacancy_id;
    else
      close csr_vacs;
    end if;
    --
  end loop;
  --
  hr_utility.set_location(l_proc,370);
  --
  -- Maintain person type usage record
  --
-- PTU : Commented call to maintain_ptu

--  hr_per_type_usage_internal.maintain_ptu
--    (p_person_id                   => p_person_id
--    ,p_action                      => 'TERM_APL'
--    ,p_business_group_id           => l_business_group_id
--    ,p_actual_termination_date     => l_hire_date
--    );
  --
  -- Call After Process User Hook for hire_employee_applicant
  --
  begin
    hr_employee_applicant_bk2.hire_employee_applicant_a
      (
       p_hire_date                  => l_hire_date,
       p_person_id                  => p_person_id,
       p_primary_assignment_id      => p_primary_assignment_id,
       p_overwrite_primary          => p_overwrite_primary,
       p_person_type_id             => p_person_type_id,
       p_per_object_version_number  => l_per_object_version_number,
       p_per_effective_start_date   => l_per_effective_start_date,
       p_per_effective_end_date     => l_per_effective_end_date,
       p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning,
       p_assign_payroll_warning     => l_assign_payroll_warning,
       p_oversubscribed_vacancy_id  => l_oversubscribed_vacancy_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for hire_employee_applicant
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    -- Set OUT parameters
    --
    p_per_object_version_number    := l_per_object_version_number;
    p_per_effective_start_date     := l_per_effective_start_date;
    p_per_effective_end_date       := l_per_effective_end_date;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 380);
    --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO hire_employee_applicant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Set OUT parameters to null
    --
    p_per_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 390);
   --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_per_object_version_number    := l_ovn;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_oversubscribed_vacancy_id    := null;
    p_unaccepted_asg_del_warning   := false;
    p_assign_payroll_warning       := false;
    ROLLBACK TO hire_employee_applicant;
    --
    --
    -- set in out parameters and set out parameters
    --

    hr_utility.set_location(' Leaving:'||l_proc, 400);
    raise;
    --
end hire_employee_applicant;
--
-- Begin #2264569
-- +-------------------------------------------------------------------------+
-- LOCATE_ELEMENT:
-- Returns the location of a particular ID in the array.
-- +-------------------------------------------------------------------------+
function locate_element(p_table t_ApplTable
                       ,p_id per_all_assignments_f.assignment_id%TYPE)
   return binary_integer is
--
  l_index number;
  l_max_ele number;
  begin
  hr_utility.set_location('IN locate_element',50);
  l_index := 0;
  l_max_ele := p_table.COUNT;
  hr_utility.trace('   table rows: '||to_char(l_max_ele));
  if l_max_ele > 0 then
     l_index := 1;
     loop
        if p_table(l_index).id = p_id then
           exit;
        end if;
       l_index := l_index + 1;
       EXIT when l_index > l_max_ele ;
     end loop;
  end if;
  hr_utility.trace('   index found : '||to_char(l_index));
  hr_utility.set_location('OUT locate_element',51);

  if l_index > l_max_ele then
     return(0);
  else
     return(l_index);
  end if;
end locate_element;
-- +-------------------------------------------------------------------------+
-- LOCATE_VALUE:
-- Returns index of first value that matches p_flag parameter.
-- +-------------------------------------------------------------------------+
function locate_value(p_table t_ApplTable
                     ,p_flag varchar2)
   return binary_integer is
  l_index number;
  l_max_ele number;
  begin
  l_index := 0;
  l_max_ele := p_table.COUNT;
  if l_max_ele > 0 then
     l_index := 1;
     loop
        if p_table(l_index).process_flag = p_flag then
           exit;
        end if;
       l_index := l_index + 1;
       EXIT when l_index > l_max_ele ;
     end loop;
  end if;

  if l_index > l_max_ele then
     return(0);
  else
     return(l_index);
  end if;
end locate_value;
--
-- +-------------------------------------------------------------------------+
-- end_date_exists
-- Returns
-- -1: if element not found
--  0: if value is null
--  1: if END DATE value has been stored in
--  2: a different value has been found.
-- +-------------------------------------------------------------------------+
function end_date_exists(p_table t_ApplTable
                    ,p_id per_all_assignments_f.assignment_id%TYPE)
   return integer is
  l_index binary_integer;
begin
   l_index := locate_element(p_table, p_id);
   if (l_index = 0) then
      return(-1);
   elsif p_table(l_index).process_flag is null then
      return(0);
   elsif p_table(l_index).process_flag = hr_employee_applicant_api.g_end_date_apl then
      return(1);
   else
     return(2);
   end if;

end end_date_exists;
-- +-------------------------------------------------------------------------+
-- is_convert:
-- Returns
-- TRUE if value exists for a particular ID or table is empty or value is null
-- Restrictions: this function should be called when processing applicant
-- assignments that have been ACCEPTED. The null value reflects a default
-- value of 'Convert into secondary'.
-- +-------------------------------------------------------------------------+
function is_convert(p_table t_ApplTable
                              ,p_id per_all_assignments_f.assignment_id%TYPE)
   return boolean is
  l_index binary_integer;
begin

   l_index := locate_element(p_table, p_id);
   if (l_index = 0) then
      return(TRUE);
   elsif (p_table(l_index).process_flag is null
       or p_table(l_index).process_flag = hr_employee_applicant_api.g_convert_apl) then
      return(TRUE);
   else
     return(FALSE);
   end if;
end is_convert;
--
function retain_exists (p_table t_ApplTable) return boolean is
begin
  return(hr_employee_applicant_api.locate_value(p_table
                   ,hr_employee_applicant_api.g_retain_apl) <> 0 );

end retain_exists;
--
-- +-------------------------------------------------------------------------+
-- TAB_IS_EMPTY:
-- Returns TRUE if PL/SQL table is empty.
-- +-------------------------------------------------------------------------+
function tab_is_empty(p_table t_ApplTable) return boolean is
begin
   return(p_table.COUNT = 0);
end tab_is_empty;
--
--
function empty_table return t_ApplTable is
 begin
   return t_EmptyAPPL;
 end;
--
function retain_flag return varchar2 is
begin
  return(g_retain_apl);
end;
--
function convert_flag return varchar2 is
begin
  return(g_convert_apl);
end;
--
function end_date_flag return varchar2 is
begin
  return(g_end_date_apl);
end;

-- end #2264569
--
-- ---------------------------------------------------------------------------
-- |-------------------------< hire_employee_applicant >---------------------|
-- ---------------------------------------------------------------------------
-- ---------------------This procedure is only for SSHR use-------------------
--
procedure hire_employee_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_asg_rec	 in out nocopy per_all_assignments_f%rowtype,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_primary_assignment_id     in      number   default null,
   p_person_type_id            in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean
  ,p_oversubscribed_vacancy_id    out nocopy  number
  ,p_called_from               in      varchar2
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'hire_employee_applicant';
  --
  l_exists                     varchar2(1);
  l_count                      number;
  l_chk_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_chk_person_id              per_all_people_f.person_id%TYPE;
  --
  l_person_type_id             number   :=  p_person_type_id;
  l_person_type_id1            number;
  l_unaccepted_asg_del_warning boolean;
  --
  l_primary_assignment_id number:=p_primary_assignment_id;
  --
  l_system_person_type         per_person_types.system_person_type%TYPE;
  l_business_group_id          per_all_people_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_application_id             per_applications.application_id%TYPE;
  l_apl_object_version_number  per_applications.application_id%TYPE;
  --
  l_hire_date                  date;
  --
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_asg_object_version_number  per_assignments_f.object_version_number%TYPE;
  --
  l_per_object_version_number  per_all_people_f.object_version_number%TYPE;
  l_ovn per_all_people_f.object_version_number%TYPE := p_per_object_version_number;
  l_employee_number            per_all_people_f.employee_number%TYPE;
  l_applicant_number           per_all_people_f.applicant_number%TYPE;
  l_npw_number                 per_all_people_f.npw_number%TYPE;
  l_per_effective_start_date   per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date     per_all_people_f.effective_end_date%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_name_combination_warning   boolean;
  l_assign_payroll_warning     boolean;
  l_orig_hire_warning          boolean;
  l_oversubscribed_vacancy_id  number;
  --Added for 5277866
  l_check_loop                 number:=0;
  --
  l_period_of_service_id       per_periods_of_service.period_of_service_id%TYPE;
  l_pds_object_version_number  per_periods_of_service.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  --
  l_primary_flag               per_assignments_f.primary_flag%TYPE;
  --
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_payroll_id_updated         boolean;
  l_other_manager_warning      boolean;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  l_hourly_salaried_warning    boolean;
  l_datetrack_update_mode      varchar2(30);
  --
  l_primary_asg_id             per_all_assignments_f.assignment_id%type;
  l_primary_ovn                per_all_assignments_f.object_version_number%type;
  l_dummy number;
  l_dummy1 number;
  l_dummy2 number;
  l_dummyv varchar2(700);
  l_dummyb boolean;
-- 2788390 starts here
  l_dummynum1  number;
-- 2788390 ends here
--added as per bug 5102160
l_gsp_post_process_warning     varchar2(2000); -- bug2999562
l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
--
  --
  cursor csr_future_asg_changes is
    select 'x'
      from per_assignments_f asg
     where asg.person_id = p_person_id
       and asg.effective_start_date > p_hire_date;
  --
  cursor csr_get_devived_details is
    select per.effective_start_date,
           ppt.system_person_type,
           per.business_group_id,
           bus.legislation_code,
           per.employee_number,
           per.npw_number,
           pap.application_id,
           pap.object_version_number
      from per_all_people_f per,
           per_business_groups bus,
           per_person_types ppt,
           per_applications pap
     where per.person_type_id    = ppt.person_type_id
       and per.business_group_id = bus.business_group_id
       and per.person_id         = pap.person_id
       and per.person_id         = p_person_id
       and l_hire_date       between per.effective_start_date
                               and per.effective_end_date
       and l_hire_date       between pap.date_received
                               and nvl(pap.date_end,hr_api.g_eot);
  --
  cursor csr_chk_asg_status is
    select count(asg.assignment_id)
      from per_assignments_f asg,
	   per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and pas.per_system_status         = 'ACCEPTED'
       and l_hire_date             between asg.effective_start_date
 		                                   and asg.effective_end_date;
  --
  cursor csr_chk_assignment_id is
    select per.person_id,
           pas.per_system_status
      from per_all_people_f per,
           per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and per.person_id                 = asg.person_id
       and l_hire_date             between per.effective_start_date
                                       and per.effective_end_date
       and asg.assignment_id             = p_primary_assignment_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date;
  --
  cursor csr_get_un_accepted is
    select asg.assignment_id,
	   asg.object_version_number
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and asg.assignment_type='A'
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status        <> 'ACCEPTED'
     order by asg.assignment_id;
  --
  /*
  cursor csr_get_accepted is
    select asg.assignment_id,
	   asg.object_version_number,
           asg.effective_start_date,
           asg.vacancy_id
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
     order by asg.assignment_id;
     */
      -- modified the above cursor for the bug 5534570
/*
In the below cursor we should not touch the other Accepted application which belong to
this employee.applicant as per SSHR requirement. So added the extra selection criteria to
pick only the application assignment which we are hiring.
SSHR Enhancement(Bug # 8536819).
*/
  cursor csr_get_accepted is
    select asg.assignment_id,
	   asg.object_version_number,
           asg.effective_start_date,
           asg.vacancy_id

	 from per_assignments_f asg,
         per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
       and asg.assignment_id  = p_primary_assignment_id   --- Added for SSHR Enhancement(Bug # 8536819).
       order by decode(asg.assignment_id,p_primary_assignment_id,1,0) desc;
--
  --
  cursor get_primary is
  select assignment_id,object_version_number, period_of_service_id -- #2468916
  from per_all_assignments_f
  where person_id=p_person_id
  and primary_flag='Y'
  and l_hire_date between effective_start_date and effective_end_date
  and assignment_type='E';
  --
  cursor get_asg(p_assignment_id number) is
    select *
    from per_all_assignments_f asg
    where asg.assignment_id=p_assignment_id
    and l_hire_date between asg.effective_start_date
                    and asg.effective_end_date;
  --
  l_asg_rec per_all_assignments_f%rowtype;
  l_primary_asg_rec per_all_assignments_f%rowtype;
  --
  cursor get_pgp(p_people_group_id number) is
    select *
    from pay_people_groups
    where people_group_id=p_people_group_id;
  --
  l_pgp_rec pay_people_groups%rowtype :=NULL;
  l_primary_pgp_rec pay_people_groups%rowtype;
  --
  cursor get_scl(p_soft_coding_keyflex_id number) is
  select *
  from hr_soft_coding_keyflex
  where soft_coding_keyflex_id=p_soft_coding_keyflex_id;
  --
  l_scl_rec hr_soft_coding_keyflex%rowtype :=NULL;
  l_primary_scl_rec hr_soft_coding_keyflex%rowtype :=NULL;
  --
  cursor get_cag(p_cagr_grade_def_id number) is
  select *
  from per_cagr_grades_def
  where cagr_grade_def_id=p_cagr_grade_def_id;
  --
  l_cag_rec per_cagr_grades_def%rowtype :=NULL;
  l_primary_cag_rec per_cagr_grades_def%rowtype;
  --
  cursor csr_vacs(p_vacancy_id number) is
  select 1
  from per_all_vacancies vac
  where vac.vacancy_id=p_vacancy_id
  and vac.number_of_openings <
    (select count(distinct assignment_id)
     from per_all_assignments_f asg
     where asg.vacancy_id=p_vacancy_id
     and asg.assignment_type='E');
--
-- Bug 4644830 Start
    cursor get_pay_proposal(ass_id per_all_assignments_f.assignment_id%type) is
    select pay_proposal_id,object_version_number,proposed_salary_n, change_date, proposal_reason -- Added For Bug 5987409 --
    from per_pay_proposals
    where assignment_id=ass_id
    and   approved = 'N'
    order by change_date desc;
    l_pay_pspl_id     per_pay_proposals.pay_proposal_id%TYPE;
    l_pay_obj_number  per_pay_proposals.object_version_number%TYPE;
    l_proposed_sal_n  per_pay_proposals.proposed_salary_n%TYPE;
    l_dummy_change_date per_pay_proposals.change_date%TYPE;
    l_inv_next_sal_date_warning  boolean := false;
    l_proposed_salary_warning  boolean := false;
    l_approved_warning  boolean := false;
    l_payroll_warning  boolean := false;
    l_proposal_reason per_pay_proposals.proposal_reason%TYPE; -- Added For Bug 5987409 --
-- Bug 4644830 End
--
-- start of bug 4641965
l_pspl_asg_id per_all_assignments_f.assignment_id%type;
cursor get_primary_proposal(ass_id per_all_assignments_f.assignment_id%type) is
     select pay_proposal_id,object_version_number
     from per_pay_proposals
     where assignment_id=ass_id
     and APPROVED='N';
 -- end 4641965

--Bug 4959033 starts here

  cursor get_business_group(p_asg_id number) is
  select distinct PAAF.business_group_id
  from   per_all_assignments_f PAAF
  where  PAAF.assignment_id=p_asg_id;
  l_bg_id number;

  cursor get_primary_approved_proposal(ass_id per_all_assignments_f.assignment_id%type) is
  select pay_proposal_id
  from per_pay_proposals
  where assignment_id=ass_id
  and APPROVED='Y';

--Bug 4959033 ends here
--
--Bug 5102289 starts here
  l_pay_basis_id  per_all_assignments_f.pay_basis_id%type;
  l_approved varchar2(10);
  cursor get_primary_pay_basis(p_asg_id number) is
         select PAAF.pay_basis_id
         from per_all_assignments_f PAAF
         where PAAF.assignment_id=p_asg_id;
--Bug 5102289 ends here
--

--- SSHR Enhancement (Bug # 8536819)---
---Cursor to find if there are any other applications other than the one
---into which we are hiring.
  cursor csr_get_all_appl_asgs is
    select 'X' from dual where exists
    ( select *
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and asg.assignment_type='A'
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and asg.assignment_id <> p_primary_assignment_id);

l_appl_count varchar2(1);
l_appl_present boolean;
---- SSHR Enhancement (Bug # 8536819)----

--- Fix For Bug # 8844816 Starts ---
  cursor csr_existing_SCL (crs_asg_id number) is
    select soft_coding_keyflex_id,payroll_id
    from per_all_assignments_f asg
    where asg.assignment_id = crs_asg_id
 -- and asg.primary_flag = 'Y'
    and trunc(sysdate) between asg.effective_start_date
    and asg.effective_end_date;
 --and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

  cursor get_scl1 is
    select soft_coding_keyflex_id
    from hr_soft_coding_keyflex
    where rownum=1;

     l_soft_coding_keyflex_id hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
     l_payroll_id per_all_assignments_f.payroll_id%type;
     l_dummy_soft_coding_keyflex_id hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
--- Fix For Bug # 8844816 Ends ---

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'hire_date'
     ,p_argument_value => p_hire_date
     );
  --
  -- Issue a savepoint.
  --
  savepoint hire_employee_applicant;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Truncate the time portion from all date parameters
  -- which are passed in.
  --
  l_hire_date                  := trunc(p_hire_date);
  l_per_object_version_number:=p_per_object_version_number;
  --
  -- Call Before Process User Hook for hire_applicant
  --
  begin
    hr_employee_applicant_bk2.hire_employee_applicant_b
      (
       p_hire_date                 => l_hire_date,
       p_person_id                 => p_person_id,
       p_primary_assignment_id     => p_primary_assignment_id,
       p_overwrite_primary         => p_overwrite_primary,
       p_person_type_id            => p_person_type_id,
       p_per_object_version_number => l_per_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for hire_employee_applicant
  --
  end;
  --
  -- Check that there are not any future changes to the assignment
  --
  hr_utility.set_location(l_proc, 30);
  --
  open csr_future_asg_changes;
  fetch csr_future_asg_changes into l_exists;
  --
  if csr_future_asg_changes%FOUND then
    --
    hr_utility.set_location(l_proc,40);
    close csr_future_asg_changes;
    --
    hr_utility.set_message(801,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc,45);
  --
  -- Get the derived details for the person DT instance
  --
  open  csr_get_devived_details;
  fetch csr_get_devived_details
   into l_per_effective_start_date,
        l_system_person_type,
        l_business_group_id,
        l_legislation_code,
        l_employee_number,
        l_npw_number,
        l_application_id,
        l_apl_object_version_number;
  if csr_get_devived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc,50);
    --
    close csr_get_devived_details;
    --
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
    --
  end if;
  close csr_get_devived_details;
  --
  hr_utility.set_location(l_proc,55);
  --
  -- Validation in addition to Row Handlers
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'EMP', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for EMP
  -- in the current business group.
  --
   per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => l_business_group_id
    ,p_expected_sys_type => 'EMP'
    );
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Check that corresponding person is of 'EMP_APL'
  -- system person type.
  --
  if l_system_person_type <> 'EMP_APL'
  then
    --
    hr_utility.set_location(l_proc,70);
    --
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- Check that corresponding person is of 'ACCEPTED' of
  -- assignment status type.
  --
  open csr_chk_asg_status;
  fetch csr_chk_asg_status into l_count;
  --close csr_chk_asg_status; -- Bug 3266844. Commented out.
  --
  if l_count = 0 then
     --
     hr_utility.set_location(l_proc,90);
     --
     close csr_chk_asg_status;
     --
     hr_utility.set_message(800,'PER_52098_APL_INV_ASG_STATUS');
     hr_utility.raise_error;
     --
  end if;
  --
  close csr_chk_asg_status;  -- Bug 3266844. Added.
  -- If we are overwriting the primary, the new primary id
  -- must be not null.
  --
  if p_overwrite_primary='Y' then
    --
    hr_utility.set_location(l_proc,100);
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_primary_assignment_id
    );
    --
    hr_utility.set_location(l_proc,110);
 else
   --the primary assignment id should be null
   l_primary_assignment_id:=null;
   hr_utility.set_location(l_proc,115);
    --
  end if;
  --
  hr_utility.set_location(l_proc,120);
  --
  -- Check p_assignment is corresponding data.
  -- The assignment record specified by P_ASSIGNMENT_ID on the hire
  -- date in the PER_ASSIGNMENTS_F table has assignment status
  -- 'ACCEPTED'.
  --
  if p_primary_assignment_id is not null then
    --
    hr_utility.set_location(l_proc,130);
    --
    open  csr_chk_assignment_id;
    fetch csr_chk_assignment_id
     into l_chk_person_id,
          l_chk_system_status;
    if csr_chk_assignment_id%NOTFOUND then
       --
       hr_utility.set_location(l_proc,140);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52099_ASG_INV_ASG_ID');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_person_id <> p_person_id then
       --
       hr_utility.set_location(l_proc,150);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52101_ASG_INV_PER_ID_COMB');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_system_status <> 'ACCEPTED' then
       --
       hr_utility.set_location(l_proc,155);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52100_ASG_INV_PER_TYPE');
       hr_utility.raise_error;
       --
    end if;
    --
    hr_utility.set_location(l_proc,160);
    --
    close csr_chk_assignment_id;
    --
  end if;
  --
  hr_utility.set_location(l_proc,170);
  --

  ------ SSHR Enhancement (Bug # 8536819)-------
  -- Check if there are any applications for the person other than the
  -- one into which we are hiring and set the value for item l_appl_present.

  open csr_get_all_appl_asgs;
  fetch csr_get_all_appl_asgs into  l_appl_count;
  if csr_get_all_appl_asgs%NOTFOUND then
  l_appl_present := FALSE;
  else
  l_appl_present := TRUE;
  end if;
  close csr_get_all_appl_asgs;

  ------ SSHR Enhancement (Bug # 8536819)-------



  -- Lock the person record in PER_ALL_PEOPLE_F ready for UPDATE at a later point.
  -- (Note: This is necessary because calling the table handlers in locking
  --        ladder order invokes an error in per_apl_upd.upd due to the person
  --        being modified by the per_per_upd.upd table handler.)
  if l_per_effective_start_date=l_hire_date then
    l_datetrack_update_mode:='CORRECTION';
  else
    l_datetrack_update_mode:='UPDATE';
  end if;
  --
  ------ SSHR Enhancement (Bug # 8536819)-------
  -- If there are no aaplication other than the one into which we are hiring
  -- then need to change the person_type. Added the below IF.
if not l_appl_present then
  per_per_shd.lck
    (p_effective_date                 => l_hire_date
    ,p_datetrack_mode                 => l_datetrack_update_mode
    ,p_person_id                      => p_person_id
    ,p_object_version_number          => l_per_object_version_number
    ,p_validation_start_date          => l_validation_start_date
    ,p_validation_end_date            => l_validation_end_date
    );

  --
  hr_utility.set_location(l_proc,180);
end if; -- SSHR Enhancement (Bug # 8536819).
  --
  -- Update the application details by calling the upd procedure in the
  -- application table handler:
  -- Date_end is set to l_hire_date - 1;
  --

  ------ SSHR Enhancement (Bug # 8536819)-------
  -- If there are no aaplication other than the one into which we are hiring
  -- then need to close the application. Added the below IF.
if not l_appl_present then
  per_apl_upd.upd
  (p_application_id                    => l_application_id
  ,p_date_end			       => l_hire_date - 1
  ,p_object_version_number             => l_apl_object_version_number
  ,p_effective_date                    => l_hire_date-1
  ,p_validate                          => false
  );
  hr_utility.set_location(l_proc,190);
end if; -- SSHR Enhancement (Bug # 8536819).
  --
  -- Set all unaccepted applicant assignments to have end date = p_hire_date -1
  -- by calling the del procedure in the PER_ASSIGNMENTS_F table handler
  -- (This is a datetrack DELETE mode operation)
  --
  --Commented the below cursor loop as it is not required to close the
  --unaccepted applications when hiring the employee.applicant in SSHR.
  --This is as per the enhancement requirements.(Bug # 8536819)
/* -----------------------------------------------------------------------------
  open csr_get_un_accepted;
  loop
    fetch csr_get_un_accepted
     into  l_assignment_id,
           l_asg_object_version_number;
    exit when csr_get_un_accepted%NOTFOUND;
    --
    hr_utility.set_location(l_proc,200);
    --
    per_asg_del.del
    (p_assignment_id              => l_assignment_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_business_group_id          => l_business_group_id
    ,p_object_version_number	  => l_asg_object_version_number
    ,p_effective_date             => l_hire_date-1
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_datetrack_mode             => 'DELETE'
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    );
    --
    hr_utility.set_location(l_proc,210);
    --
    l_unaccepted_asg_del_warning := TRUE;
    --
  end loop;
  --
  close csr_get_un_accepted;
-------------------------------------------------------------------------------*/
  --
  hr_utility.set_location(l_proc, 220);

-- PTU : Changes

  l_person_type_id1   := hr_person_type_usage_info.get_default_person_type_id
                                         (l_business_group_id,
                                          'EMP');
-- PTU : End of Changes

  hr_utility.set_location(l_proc, 225);

  --
  -- Update the person details by calling upd procedure in
  -- the per_all_people_f table.
  --
  l_applicant_number:=hr_api.g_varchar2;
  l_employee_number:=hr_api.g_varchar2;

  ------ SSHR Enhancement (Bug # 8536819)-------
  -- If there are no aaplication other than the one into which we are hiring
  -- then need to change the person_type. Added the below IF.
if not l_appl_present then

  per_per_upd.upd
  (p_person_id                    => p_person_id
  ,p_effective_date               => l_hire_date
  ,p_applicant_number             => l_applicant_number
  ,p_employee_number              => l_employee_number
  ,p_person_type_id               => l_person_type_id1
  ,p_object_version_number        => l_per_object_version_number
  ,p_datetrack_mode               => l_datetrack_update_mode
  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  ,p_npw_number                   => l_npw_number
  );
  --
  hr_utility.set_location(l_proc,230);

-- PTU : Following Code has been added
--
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => p_person_id
,p_person_type_id       => l_person_type_id
,p_datetrack_update_mode => l_datetrack_update_mode
);
--
  l_person_type_id1  := hr_person_type_usage_info.get_default_person_type_id
                                        (l_business_group_id,
                                         'EX_APL');
--
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => p_person_id
,p_person_type_id       => l_person_type_id1
,p_datetrack_update_mode => l_datetrack_update_mode
);
--
-- PTU : End of changes

end if;  -- SSHR Enhancement.(Bug # 8536819)


  --
  --  All accepted applicant assignments are changed to employee assignments
  --  with default employee assignment.(ACTIVE_ASSIGN)
  --  1) Derive assignment_status_type_id for default 'ACTIVE_ASSIGN'.
  --  2) Update the assignments by calling the upd procedure in the
  --     PER_ASSIGNMENTS_F table handler(This is a datetrack UPDATE mode
  --     operation)
  --  3) When the accepted assignments are multiple, the primary flag of the
  --     record not specified by P_ASSIGNMENT_ID is set to 'N'.
  --
  per_asg_bus1.chk_assignment_status_type
  (p_assignment_status_type_id => l_assignment_status_type_id
  ,p_business_group_id         => l_business_group_id
  ,p_legislation_code          => l_legislation_code
  ,p_expected_system_status    => 'ACTIVE_ASSIGN'
  );
  --
  hr_utility.set_location(l_proc,240);
  --
  l_oversubscribed_vacancy_id :=null;

--- Fix For Bug # 8844816 Starts ---
  open get_scl1;
  fetch get_scl1 into l_dummy_soft_coding_keyflex_id;
  close get_scl1;

  open csr_existing_SCL(p_primary_assignment_id);
  fetch csr_existing_SCL into l_soft_coding_keyflex_id,l_payroll_id;
  close csr_existing_SCL;

  if l_soft_coding_keyflex_id is null and l_payroll_id is not null then
     l_soft_coding_keyflex_id := l_dummy_soft_coding_keyflex_id;
  else
     l_soft_coding_keyflex_id := hr_api.g_number;
  end if;
--- Fix For Bug # 8844816 Ends ---

  --
  -- #2468916: Need to retrieve the period of service id
  open get_primary;
  fetch get_primary into l_primary_asg_id,l_primary_ovn, l_period_of_service_id;
  close get_primary;
  --
  for asg_rec in csr_get_accepted loop
    --
    hr_utility.set_location(l_proc,250);
      --
     if asg_rec.effective_start_date=l_hire_date then
      l_datetrack_update_mode:='CORRECTION';
    else
      l_datetrack_update_mode:='UPDATE';
    end if;
    --
    if asg_rec.assignment_id <> p_primary_assignment_id or p_overwrite_primary ='N' then
       --
      per_asg_upd.upd
     (p_assignment_id                => asg_rec.assignment_id,
      p_object_version_number        => asg_rec.object_version_number,
      p_effective_date               => l_hire_date,
      p_datetrack_mode               => l_datetrack_update_mode,
      p_assignment_status_type_id    => l_assignment_status_type_id,
      p_assignment_type              => 'E',
      p_primary_flag                 => 'N',
      p_period_of_service_id         => l_period_of_service_id,
      --
      p_effective_start_date         => l_effective_start_date,
      p_effective_end_date           => l_effective_end_date,
      p_business_group_id            => l_business_group_id,
      p_comment_id                   => l_comment_id,
      p_validation_start_date        => l_validation_start_date,
      p_validation_end_date          => l_validation_end_date,
      p_payroll_id_updated           => l_payroll_id_updated,
      p_other_manager_warning        => l_other_manager_warning,
      p_no_managers_warning          => l_no_managers_warning,
      p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
      p_hourly_salaried_warning      => l_hourly_salaried_warning,
      p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id  --- Fix For Bug # 8844816
      );
      --
      hr_utility.set_location(l_proc,260);
--The below has been commented as part of bug fix 5481530
--      if asg_rec.assignment_id = p_primary_assignment_id then
      if asg_rec.assignment_id = l_primary_assignment_id then
        hr_assignment_api.set_new_primary_asg
        (p_validate              => false
        ,p_effective_date        => l_hire_date
        ,p_person_id             => p_person_id
        ,p_assignment_id         => asg_rec.assignment_id
        ,p_object_version_number => asg_rec.object_version_number
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date
        );
      end if;
-- Bug 4644830 Start
       OPEN get_pay_proposal(asg_rec.assignment_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason for Bug # 5987409 --
       if get_pay_proposal%found then
          close get_pay_proposal;
          hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning           => l_approved_warning,
                        p_payroll_warning            => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

       else
          close get_pay_proposal;
       end if;
-- Bug 4644830 End
-- Bug 4630129 Starts
   elsif asg_rec.assignment_id = p_primary_assignment_id and p_overwrite_primary ='Y' then
-- Hire the new secondary Applicant assignment.
      hr_utility.set_location(l_proc,261);
      per_asg_upd.upd
     (p_assignment_id                => asg_rec.assignment_id,
      p_object_version_number        => asg_rec.object_version_number,
      p_effective_date               => l_hire_date,
      p_datetrack_mode               => l_datetrack_update_mode,
      p_assignment_status_type_id    => l_assignment_status_type_id,
      p_assignment_type              => 'E',
      p_primary_flag                 => 'N',
      p_period_of_service_id         => l_period_of_service_id,
      --
      p_effective_start_date         => l_effective_start_date,
      p_effective_end_date           => l_effective_end_date,
      p_business_group_id            => l_business_group_id,
      p_comment_id                   => l_comment_id,
      p_validation_start_date        => l_validation_start_date,
      p_validation_end_date          => l_validation_end_date,
      p_payroll_id_updated           => l_payroll_id_updated,
      p_other_manager_warning        => l_other_manager_warning,
      p_no_managers_warning          => l_no_managers_warning,
      p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
      p_hourly_salaried_warning      => l_hourly_salaried_warning,
      p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id  --- Fix For Bug # 8844816
      );
-- Make the new secondary Applicant assignment Primary.
      hr_utility.set_location(l_proc,262);
      hr_assignment_api.set_new_primary_asg
      (p_validate              => false
      ,p_effective_date        => l_hire_date
      ,p_person_id             => p_person_id
      ,p_assignment_id         => asg_rec.assignment_id
      ,p_object_version_number => asg_rec.object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
        );
      hr_utility.set_location(l_proc,263);
-- Bug 4630129 Ends
-- Bug 4644830 Start
       OPEN get_pay_proposal(asg_rec.assignment_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason for Bug # 5987409 --
       if get_pay_proposal%found then
          close get_pay_proposal;
          hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning           => l_approved_warning,
                        p_payroll_warning            => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

       else
          close get_pay_proposal;
       end if;
-- Bug 4644830 End

 -- fix for the bug 4777901 starts here

 elsif  p_overwrite_primary ='W' then
 --
-- bug 5024006 fix  starts here
--
if l_check_loop=0 then

  open get_primary;
      fetch get_primary into l_primary_asg_id,l_primary_ovn,  l_period_of_service_id; -- #2468916
      close get_primary;
      --
      hr_utility.set_location(l_proc, 264);
      --
    if p_asg_rec.assignment_id is not null then
       l_asg_rec := p_asg_rec;
    else
      open get_asg(asg_rec.assignment_id);
      fetch get_asg into l_asg_rec;
      close get_asg;
    end if;

      ---changes for 4959033 starts here
      open get_primary_approved_proposal(l_primary_asg_id);
      fetch get_primary_approved_proposal into l_pay_pspl_id;

      if get_primary_approved_proposal%found then
      close get_primary_approved_proposal;

          if l_asg_rec.pay_basis_id  is null then
           hr_utility.set_message(800,'HR_289767_SALARY_BASIS_IS_NULL');
           hr_utility.raise_error;
          end if;
      --Added else to close the cursor--5277866
       else
      close get_primary_approved_proposal;
       end if;
      ---changes for 4959033 ends here

       if l_asg_rec.people_group_id is not null then
              --
              hr_utility.set_location(l_proc, 265);
              --
              open get_pgp(l_asg_rec.people_group_id);
              fetch get_pgp into l_pgp_rec;
              close get_pgp;

      end if;

      if l_asg_rec.soft_coding_keyflex_id is not null then
              --
              hr_utility.set_location(l_proc, 266);
              --
              open get_scl(l_asg_rec.soft_coding_keyflex_id);
              fetch get_scl into l_scl_rec;
              close get_scl;

	end if;
            --
            if l_asg_rec.cagr_grade_def_id is not null then
              --
              hr_utility.set_location(l_proc, 267);
              --
              open get_cag(l_asg_rec.cagr_grade_def_id);
              fetch get_cag into l_cag_rec;
              close get_cag;
             end if;
      --

      hr_utility.set_location(l_proc, 268);
      --

      --The below call has been commented as per bug 5102160
      -- soft_coding_keyflex_id is passed by calling the new update_emp_asg_criteria procedure

      /*hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_dummy
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      );*/

      hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_people_group_id              => l_dummy
      ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
      );

      --
      hr_utility.set_location(l_proc, 269);
      --
      hr_assignment_api.update_emp_asg
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_supervisor_id                => l_asg_rec.supervisor_id
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_date_probation_end           => l_asg_rec.date_probation_end
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_perf_review_period           => l_asg_rec.perf_review_period
      ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
      ,p_probation_period             => l_asg_rec.probation_period
      ,p_probation_unit               => l_asg_rec.probation_unit
      ,p_sal_review_period            => l_asg_rec.sal_review_period
      ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
      ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
      ,p_hourly_salaried_code         => l_asg_rec.hourly_salaried_code
      ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_ass_attribute1               => l_asg_rec.ass_attribute1
      ,p_ass_attribute2               => l_asg_rec.ass_attribute2
      ,p_ass_attribute3               => l_asg_rec.ass_attribute3
      ,p_ass_attribute4               => l_asg_rec.ass_attribute4
      ,p_ass_attribute5               => l_asg_rec.ass_attribute5
      ,p_ass_attribute6               => l_asg_rec.ass_attribute6
      ,p_ass_attribute7               => l_asg_rec.ass_attribute7
      ,p_ass_attribute8               => l_asg_rec.ass_attribute8
      ,p_ass_attribute9               => l_asg_rec.ass_attribute9
      ,p_ass_attribute10              => l_asg_rec.ass_attribute10
      ,p_ass_attribute11              => l_asg_rec.ass_attribute11
      ,p_ass_attribute12              => l_asg_rec.ass_attribute12
      ,p_ass_attribute13              => l_asg_rec.ass_attribute13
      ,p_ass_attribute14              => l_asg_rec.ass_attribute14
      ,p_ass_attribute15              => l_asg_rec.ass_attribute15
      ,p_ass_attribute16              => l_asg_rec.ass_attribute16
      ,p_ass_attribute17              => l_asg_rec.ass_attribute17
      ,p_ass_attribute18              => l_asg_rec.ass_attribute18
      ,p_ass_attribute19              => l_asg_rec.ass_attribute19
      ,p_ass_attribute20              => l_asg_rec.ass_attribute20
      ,p_ass_attribute21              => l_asg_rec.ass_attribute21
      ,p_ass_attribute22              => l_asg_rec.ass_attribute22
      ,p_ass_attribute23              => l_asg_rec.ass_attribute23
      ,p_ass_attribute24              => l_asg_rec.ass_attribute24
      ,p_ass_attribute25              => l_asg_rec.ass_attribute25
      ,p_ass_attribute26              => l_asg_rec.ass_attribute26
      ,p_ass_attribute27              => l_asg_rec.ass_attribute27
      ,p_ass_attribute28              => l_asg_rec.ass_attribute28
      ,p_ass_attribute29              => l_asg_rec.ass_attribute29
      ,p_ass_attribute30              => l_asg_rec.ass_attribute30
      ,p_segment1                     => l_scl_rec.segment1
      ,p_segment2                     => l_scl_rec.segment2
      ,p_segment3                     => l_scl_rec.segment3
      ,p_segment4                     => l_scl_rec.segment4
      ,p_segment5                     => l_scl_rec.segment5
      ,p_segment6                     => l_scl_rec.segment6
      ,p_segment7                     => l_scl_rec.segment7
      ,p_segment8                     => l_scl_rec.segment8
      ,p_segment9                     => l_scl_rec.segment9
      ,p_segment10                    => l_scl_rec.segment10
      ,p_segment11                    => l_scl_rec.segment11
      ,p_segment12                    => l_scl_rec.segment12
      ,p_segment13                    => l_scl_rec.segment13
      ,p_segment14                    => l_scl_rec.segment14
      ,p_segment15                    => l_scl_rec.segment15
      ,p_segment16                    => l_scl_rec.segment16
      ,p_segment17                    => l_scl_rec.segment17
      ,p_segment18                    => l_scl_rec.segment18
      ,p_segment19                    => l_scl_rec.segment19
      ,p_segment20                    => l_scl_rec.segment20
      ,p_segment21                    => l_scl_rec.segment21
      ,p_segment22                    => l_scl_rec.segment22
      ,p_segment23                    => l_scl_rec.segment23
      ,p_segment24                    => l_scl_rec.segment24
      ,p_segment25                    => l_scl_rec.segment25
      ,p_segment26                    => l_scl_rec.segment26
      ,p_segment27                    => l_scl_rec.segment27
      ,p_segment28                    => l_scl_rec.segment28
      ,p_segment29                    => l_scl_rec.segment29
      ,p_segment30                    => l_scl_rec.segment30
      ,p_contract_id                  => l_asg_rec.contract_id
      ,p_establishment_id             => l_asg_rec.establishment_id
      ,p_collective_agreement_id      => l_asg_rec.collective_agreement_id
      ,p_cagr_id_flex_num             => l_asg_rec.cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_rec.segment1
      ,p_cag_segment2                 => l_cag_rec.segment2
      ,p_cag_segment3                 => l_cag_rec.segment3
      ,p_cag_segment4                 => l_cag_rec.segment4
      ,p_cag_segment5                 => l_cag_rec.segment5
      ,p_cag_segment6                 => l_cag_rec.segment6
      ,p_cag_segment7                 => l_cag_rec.segment7
      ,p_cag_segment8                 => l_cag_rec.segment8
      ,p_cag_segment9                 => l_cag_rec.segment9
      ,p_cag_segment10                => l_cag_rec.segment10
      ,p_cag_segment11                => l_cag_rec.segment11
      ,p_cag_segment12                => l_cag_rec.segment12
      ,p_cag_segment13                => l_cag_rec.segment13
      ,p_cag_segment14                => l_cag_rec.segment14
      ,p_cag_segment15                => l_cag_rec.segment15
      ,p_cag_segment16                => l_cag_rec.segment16
      ,p_cag_segment17                => l_cag_rec.segment17
      ,p_cag_segment18                => l_cag_rec.segment18
      ,p_cag_segment19                => l_cag_rec.segment19
      ,p_cag_segment20                => l_cag_rec.segment20
      ,p_notice_period		      => l_asg_rec.notice_period
      ,p_notice_period_uom            => l_asg_rec.notice_period_uom
      ,p_employee_category            => l_asg_rec.employee_category
      ,p_work_at_home		      => l_asg_rec.work_at_home
      ,p_job_post_source_name	      => l_asg_rec.job_post_source_name
      ,p_cagr_grade_def_id            => l_dummynum1 -- Bug # 2788390 modified l_dummy to l_dummynum1.
      ,p_cagr_concatenated_segments   => l_dummyv
      ,p_concatenated_segments        => l_dummyv
      ,p_soft_coding_keyflex_id       => l_dummy1
      ,p_comment_id                   => l_dummy2
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_no_managers_warning          => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_hourly_salaried_warning      => l_dummyb
      );
      --
      hr_utility.set_location(l_proc, 271);

--Fix For Bug # 5987409 Starts -----

UPDATE PER_ASSIGNMENTS_F PAF SET PAF.VACANCY_ID =l_asg_rec.vacancy_id ,
PAF.RECRUITER_ID =l_asg_rec.recruiter_id
WHERE  PAF.ASSIGNMENT_ID = l_primary_asg_id AND
PAF.EFFECTIVE_START_DATE = l_effective_start_date AND
PAF.EFFECTIVE_END_DATE = l_effective_end_date;

--Fix For Bug # 5987409 Starts -----


      --
      -- now end date the application
      --
      per_asg_del.del
      (p_assignment_id              => l_asg_rec.assignment_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_business_group_id          => l_business_group_id
      ,p_object_version_number	    => l_asg_rec.object_version_number
      ,p_effective_date             => l_hire_date-1
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      ,p_datetrack_mode             => 'DELETE'
      ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
      --
      hr_utility.set_location(l_proc, 272);
      --
      --

       l_pspl_asg_id :=asg_rec.assignment_id;


       OPEN get_pay_proposal(l_pspl_asg_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; -- Added Proposal_Reason For Bug # 5987409 --
       if get_pay_proposal%found then
           /*  l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
            open get_primary_proposal(l_primary_asg_id);
            fetch get_primary_proposal into l_pay_pspl_id,l_pay_obj_number;
              if get_primary_proposal%found then
                 close get_primary_proposal; */
            update per_pay_proposals set assignment_id = l_primary_asg_id
                                                     where pay_proposal_id = l_pay_pspl_id;
            l_pay_obj_number := l_pay_obj_number +1;
                 hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
             	        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);
           /*  else
	     close get_primary_proposal;
	     l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id,
                        p_assignment_id              => l_primary_asg_id,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

             end if; */
	--
      end if;
     --
        close get_pay_proposal;
     --
   l_check_loop := l_check_loop +1;

 end if;

     -- fix for the bug 5024006 ends here

    else
      --
      hr_utility.set_location(l_proc, 270);
      --
      -- we must update the old assignment with the new assignment record
      --
      open get_primary;
      fetch get_primary into l_primary_asg_id,l_primary_ovn,  l_period_of_service_id; -- #2468916
      close get_primary;
      --
      hr_utility.set_location(l_proc, 280);
      --
    if p_asg_rec.assignment_id is not null then
       l_asg_rec := p_asg_rec;
    else
      open get_asg(asg_rec.assignment_id);
      fetch get_asg into l_asg_rec;
      close get_asg;
    end if;
      --
      hr_utility.set_location(l_proc, 290);
      --
      if l_asg_rec.people_group_id is not null then
        --
        hr_utility.set_location(l_proc, 300);
        --
        open get_pgp(l_asg_rec.people_group_id);
        fetch get_pgp into l_pgp_rec;
        close get_pgp;
      end if;
      --
      if l_asg_rec.soft_coding_keyflex_id is not null then
        --
        hr_utility.set_location(l_proc, 310);
        --
        open get_scl(l_asg_rec.soft_coding_keyflex_id);
        fetch get_scl into l_scl_rec;
        close get_scl;
      end if;
      --
      if l_asg_rec.cagr_grade_def_id is not null then
        --
        hr_utility.set_location(l_proc, 320);
        --
        open get_cag(l_asg_rec.cagr_grade_def_id);
        fetch get_cag into l_cag_rec;
        close get_cag;
      end if;
      --
      hr_utility.set_location(l_proc, 330);
      --
      if p_overwrite_primary = 'V' then
        --
        open get_asg(l_primary_asg_id);
        fetch get_asg into l_primary_asg_rec;
        close get_asg;
        --
        if l_primary_asg_rec.people_group_id is not null then
          open get_pgp(l_primary_asg_rec.people_group_id);
          fetch get_pgp into l_primary_pgp_rec;
          close get_pgp;
        end if;
        --
        if l_primary_asg_rec.soft_coding_keyflex_id is not null then
          open get_scl(l_primary_asg_rec.soft_coding_keyflex_id);
          fetch get_scl into l_primary_scl_rec;
          close get_scl;
        end if;
        --
        if l_primary_asg_rec.cagr_grade_def_id is not null then
          open get_cag(l_primary_asg_rec.cagr_grade_def_id);
          fetch get_cag into l_primary_cag_rec;
          close get_cag;
        end if;
        --
        -- Merge new and old primary assignments, giving preference to the
        -- new one.
        --
	--Bug 4234518
	--
	 l_asg_rec.employee_category :=  NVL(l_asg_rec.employee_category,l_primary_asg_rec.employee_category);
	 --Bug fix 4234518 ends here
	 --
        l_asg_rec.employment_category := NVL(l_asg_rec.employment_category,l_primary_asg_rec.employment_category);
        l_asg_rec.grade_id := NVL(l_asg_rec.grade_id,l_primary_asg_rec.grade_id);
        l_asg_rec.job_id := NVL(l_asg_rec.job_id,l_primary_asg_rec.job_id);
        l_asg_rec.location_id := NVL(l_asg_rec.location_id,l_primary_asg_rec.location_id);
        l_asg_rec.organization_id := NVL(l_asg_rec.organization_id,l_primary_asg_rec.organization_id);
        l_asg_rec.payroll_id := NVL(l_asg_rec.payroll_id,l_primary_asg_rec.payroll_id);
        l_asg_rec.pay_basis_id := NVL(l_asg_rec.pay_basis_id,l_primary_asg_rec.pay_basis_id);
        l_asg_rec.position_id := NVL(l_asg_rec.position_id,l_primary_asg_rec.position_id);
        l_asg_rec.special_ceiling_step_id := NVL(l_asg_rec.special_ceiling_step_id,l_primary_asg_rec.special_ceiling_step_id);
        --
        l_pgp_rec.segment1  := NVL(l_pgp_rec.segment1, l_primary_pgp_rec.segment1);
        l_pgp_rec.segment2  := NVL(l_pgp_rec.segment2, l_primary_pgp_rec.segment2);
        l_pgp_rec.segment3  := NVL(l_pgp_rec.segment3, l_primary_pgp_rec.segment3);
        l_pgp_rec.segment4  := NVL(l_pgp_rec.segment4, l_primary_pgp_rec.segment4);
        l_pgp_rec.segment5  := NVL(l_pgp_rec.segment5, l_primary_pgp_rec.segment5);
        l_pgp_rec.segment6  := NVL(l_pgp_rec.segment6, l_primary_pgp_rec.segment6);
        l_pgp_rec.segment7  := NVL(l_pgp_rec.segment7, l_primary_pgp_rec.segment7);
        l_pgp_rec.segment8  := NVL(l_pgp_rec.segment8, l_primary_pgp_rec.segment8);   --- Fix For Bug # 8758419
        l_pgp_rec.segment9  := NVL(l_pgp_rec.segment9, l_primary_pgp_rec.segment9);
        l_pgp_rec.segment10 := NVL(l_pgp_rec.segment10,l_primary_pgp_rec.segment10);
        l_pgp_rec.segment11 := NVL(l_pgp_rec.segment11,l_primary_pgp_rec.segment11);
        l_pgp_rec.segment12 := NVL(l_pgp_rec.segment12,l_primary_pgp_rec.segment12);
        l_pgp_rec.segment13 := NVL(l_pgp_rec.segment13,l_primary_pgp_rec.segment13);
        l_pgp_rec.segment14 := NVL(l_pgp_rec.segment14,l_primary_pgp_rec.segment14);
        l_pgp_rec.segment15 := NVL(l_pgp_rec.segment15,l_primary_pgp_rec.segment15);
        l_pgp_rec.segment16 := NVL(l_pgp_rec.segment16,l_primary_pgp_rec.segment16);
        l_pgp_rec.segment17 := NVL(l_pgp_rec.segment17,l_primary_pgp_rec.segment17);
        l_pgp_rec.segment18 := NVL(l_pgp_rec.segment18,l_primary_pgp_rec.segment18);
        l_pgp_rec.segment19 := NVL(l_pgp_rec.segment19,l_primary_pgp_rec.segment19);
        l_pgp_rec.segment20 := NVL(l_pgp_rec.segment20,l_primary_pgp_rec.segment20);
        l_pgp_rec.segment21 := NVL(l_pgp_rec.segment21,l_primary_pgp_rec.segment21);
        l_pgp_rec.segment22 := NVL(l_pgp_rec.segment22,l_primary_pgp_rec.segment22);
        l_pgp_rec.segment23 := NVL(l_pgp_rec.segment23,l_primary_pgp_rec.segment23);
        l_pgp_rec.segment24 := NVL(l_pgp_rec.segment24,l_primary_pgp_rec.segment24);
        l_pgp_rec.segment25 := NVL(l_pgp_rec.segment25,l_primary_pgp_rec.segment25);
        l_pgp_rec.segment26 := NVL(l_pgp_rec.segment26,l_primary_pgp_rec.segment26);
        l_pgp_rec.segment27 := NVL(l_pgp_rec.segment27,l_primary_pgp_rec.segment27);
        l_pgp_rec.segment28 := NVL(l_pgp_rec.segment28,l_primary_pgp_rec.segment28);
        l_pgp_rec.segment29 := NVL(l_pgp_rec.segment29,l_primary_pgp_rec.segment29);
        l_pgp_rec.segment30 := NVL(l_pgp_rec.segment30,l_primary_pgp_rec.segment30);
        --
--        l_asg_rec.assignment_number := NVL(l_asg_rec.assignment_number,l_primary_asg_rec.assignment_number);
        l_asg_rec.bargaining_unit_code := NVL(l_asg_rec.bargaining_unit_code,l_primary_asg_rec.bargaining_unit_code);
--        l_asg_rec.change_reason := NVL(l_asg_rec.change_reason,l_primary_asg_rec.change_reason);
        l_asg_rec.collective_agreement_id := NVL(l_asg_rec.collective_agreement_id,l_primary_asg_rec.collective_agreement_id);
        l_asg_rec.contract_id := NVL(l_asg_rec.contract_id,l_primary_asg_rec.contract_id);
        l_asg_rec.date_probation_end := NVL(l_asg_rec.date_probation_end,l_primary_asg_rec.date_probation_end);
        l_asg_rec.default_code_comb_id := NVL(l_asg_rec.default_code_comb_id,l_primary_asg_rec.default_code_comb_id);
        l_asg_rec.establishment_id := NVL(l_asg_rec.establishment_id,l_primary_asg_rec.establishment_id);
        l_asg_rec.frequency := NVL(l_asg_rec.frequency,l_primary_asg_rec.frequency);
        l_asg_rec.hourly_salaried_code := NVL(l_asg_rec.hourly_salaried_code,l_primary_asg_rec.hourly_salaried_code);
        l_asg_rec.internal_address_line := NVL(l_asg_rec.internal_address_line,l_primary_asg_rec.internal_address_line);
        l_asg_rec.labour_union_member_flag := NVL(l_asg_rec.labour_union_member_flag,l_primary_asg_rec.labour_union_member_flag);
        l_asg_rec.manager_flag := NVL(l_asg_rec.manager_flag,l_primary_asg_rec.manager_flag);
        l_asg_rec.normal_hours := NVL(l_asg_rec.normal_hours,l_primary_asg_rec.normal_hours);
        l_asg_rec.perf_review_period := NVL(l_asg_rec.perf_review_period,l_primary_asg_rec.perf_review_period);
        l_asg_rec.perf_review_period_frequency := NVL(l_asg_rec.perf_review_period_frequency,l_primary_asg_rec.perf_review_period_frequency);
        l_asg_rec.probation_period := NVL(l_asg_rec.probation_period,l_primary_asg_rec.probation_period);
        l_asg_rec.probation_unit := NVL(l_asg_rec.probation_unit,l_primary_asg_rec.probation_unit);
        l_asg_rec.sal_review_period := NVL(l_asg_rec.sal_review_period,l_primary_asg_rec.sal_review_period);
        l_asg_rec.sal_review_period_frequency := NVL(l_asg_rec.sal_review_period_frequency,l_primary_asg_rec.sal_review_period_frequency);
        l_asg_rec.set_of_books_id := NVL(l_asg_rec.set_of_books_id,l_primary_asg_rec.set_of_books_id);
        l_asg_rec.source_type := NVL(l_asg_rec.source_type,l_primary_asg_rec.source_type);
        l_asg_rec.supervisor_id := NVL(l_asg_rec.supervisor_id,l_primary_asg_rec.supervisor_id);
        l_asg_rec.time_normal_finish := NVL(l_asg_rec.time_normal_finish,l_primary_asg_rec.time_normal_finish);
        l_asg_rec.time_normal_start := NVL(l_asg_rec.time_normal_start,l_primary_asg_rec.time_normal_start);
        --
        if (l_asg_rec.ass_attribute_category = l_primary_asg_rec.ass_attribute_category) then
          l_asg_rec.ass_attribute1  := NVL(l_asg_rec.ass_attribute1, l_primary_asg_rec.ass_attribute1);
          l_asg_rec.ass_attribute2  := NVL(l_asg_rec.ass_attribute2, l_primary_asg_rec.ass_attribute2);
          l_asg_rec.ass_attribute3  := NVL(l_asg_rec.ass_attribute3, l_primary_asg_rec.ass_attribute3);
          l_asg_rec.ass_attribute4  := NVL(l_asg_rec.ass_attribute4, l_primary_asg_rec.ass_attribute4);
          l_asg_rec.ass_attribute5  := NVL(l_asg_rec.ass_attribute5, l_primary_asg_rec.ass_attribute5);
          l_asg_rec.ass_attribute6  := NVL(l_asg_rec.ass_attribute6, l_primary_asg_rec.ass_attribute6);
          l_asg_rec.ass_attribute7  := NVL(l_asg_rec.ass_attribute7, l_primary_asg_rec.ass_attribute7);
          l_asg_rec.ass_attribute8  := NVL(l_asg_rec.ass_attribute8, l_primary_asg_rec.ass_attribute8);
          l_asg_rec.ass_attribute9  := NVL(l_asg_rec.ass_attribute9, l_primary_asg_rec.ass_attribute9);
          l_asg_rec.ass_attribute10 := NVL(l_asg_rec.ass_attribute10,l_primary_asg_rec.ass_attribute10);
          l_asg_rec.ass_attribute11 := NVL(l_asg_rec.ass_attribute11,l_primary_asg_rec.ass_attribute11);
          l_asg_rec.ass_attribute12 := NVL(l_asg_rec.ass_attribute12,l_primary_asg_rec.ass_attribute12);
          l_asg_rec.ass_attribute13 := NVL(l_asg_rec.ass_attribute13,l_primary_asg_rec.ass_attribute13);
          l_asg_rec.ass_attribute14 := NVL(l_asg_rec.ass_attribute14,l_primary_asg_rec.ass_attribute14);
          l_asg_rec.ass_attribute15 := NVL(l_asg_rec.ass_attribute15,l_primary_asg_rec.ass_attribute15);
          l_asg_rec.ass_attribute16 := NVL(l_asg_rec.ass_attribute16,l_primary_asg_rec.ass_attribute16);
          l_asg_rec.ass_attribute17 := NVL(l_asg_rec.ass_attribute17,l_primary_asg_rec.ass_attribute17);
          l_asg_rec.ass_attribute18 := NVL(l_asg_rec.ass_attribute18,l_primary_asg_rec.ass_attribute18);
          l_asg_rec.ass_attribute19 := NVL(l_asg_rec.ass_attribute19,l_primary_asg_rec.ass_attribute19);
          l_asg_rec.ass_attribute20 := NVL(l_asg_rec.ass_attribute20,l_primary_asg_rec.ass_attribute20);
          l_asg_rec.ass_attribute21 := NVL(l_asg_rec.ass_attribute21,l_primary_asg_rec.ass_attribute21);
          l_asg_rec.ass_attribute22 := NVL(l_asg_rec.ass_attribute22,l_primary_asg_rec.ass_attribute22);
          l_asg_rec.ass_attribute23 := NVL(l_asg_rec.ass_attribute23,l_primary_asg_rec.ass_attribute23);
          l_asg_rec.ass_attribute24 := NVL(l_asg_rec.ass_attribute24,l_primary_asg_rec.ass_attribute24);
          l_asg_rec.ass_attribute25 := NVL(l_asg_rec.ass_attribute25,l_primary_asg_rec.ass_attribute25);
          l_asg_rec.ass_attribute26 := NVL(l_asg_rec.ass_attribute26,l_primary_asg_rec.ass_attribute26);
          l_asg_rec.ass_attribute27 := NVL(l_asg_rec.ass_attribute27,l_primary_asg_rec.ass_attribute27);
          l_asg_rec.ass_attribute28 := NVL(l_asg_rec.ass_attribute28,l_primary_asg_rec.ass_attribute28);
          l_asg_rec.ass_attribute29 := NVL(l_asg_rec.ass_attribute29,l_primary_asg_rec.ass_attribute29);
          l_asg_rec.ass_attribute30 := NVL(l_asg_rec.ass_attribute30,l_primary_asg_rec.ass_attribute30);
        elsif (l_asg_rec.ass_attribute_category is null) then
          l_asg_rec.ass_attribute_category := l_primary_asg_rec.ass_attribute_category;
          l_asg_rec.ass_attribute1  := l_primary_asg_rec.ass_attribute1;
          l_asg_rec.ass_attribute2  := l_primary_asg_rec.ass_attribute2;
          l_asg_rec.ass_attribute3  := l_primary_asg_rec.ass_attribute3;
          l_asg_rec.ass_attribute4  := l_primary_asg_rec.ass_attribute4;
          l_asg_rec.ass_attribute5  := l_primary_asg_rec.ass_attribute5;
          l_asg_rec.ass_attribute6  := l_primary_asg_rec.ass_attribute6;
          l_asg_rec.ass_attribute7  := l_primary_asg_rec.ass_attribute7;
          l_asg_rec.ass_attribute8  := l_primary_asg_rec.ass_attribute8;
          l_asg_rec.ass_attribute9  := l_primary_asg_rec.ass_attribute9;
          l_asg_rec.ass_attribute10 := l_primary_asg_rec.ass_attribute10;
          l_asg_rec.ass_attribute11 := l_primary_asg_rec.ass_attribute11;
          l_asg_rec.ass_attribute12 := l_primary_asg_rec.ass_attribute12;
          l_asg_rec.ass_attribute13 := l_primary_asg_rec.ass_attribute13;
          l_asg_rec.ass_attribute14 := l_primary_asg_rec.ass_attribute14;
          l_asg_rec.ass_attribute15 := l_primary_asg_rec.ass_attribute15;
          l_asg_rec.ass_attribute16 := l_primary_asg_rec.ass_attribute16;
          l_asg_rec.ass_attribute17 := l_primary_asg_rec.ass_attribute17;
          l_asg_rec.ass_attribute18 := l_primary_asg_rec.ass_attribute18;
          l_asg_rec.ass_attribute19 := l_primary_asg_rec.ass_attribute19;
          l_asg_rec.ass_attribute20 := l_primary_asg_rec.ass_attribute20;
          l_asg_rec.ass_attribute21 := l_primary_asg_rec.ass_attribute21;
          l_asg_rec.ass_attribute22 := l_primary_asg_rec.ass_attribute22;
          l_asg_rec.ass_attribute23 := l_primary_asg_rec.ass_attribute23;
          l_asg_rec.ass_attribute24 := l_primary_asg_rec.ass_attribute24;
          l_asg_rec.ass_attribute25 := l_primary_asg_rec.ass_attribute25;
          l_asg_rec.ass_attribute26 := l_primary_asg_rec.ass_attribute26;
          l_asg_rec.ass_attribute27 := l_primary_asg_rec.ass_attribute27;
          l_asg_rec.ass_attribute28 := l_primary_asg_rec.ass_attribute28;
          l_asg_rec.ass_attribute29 := l_primary_asg_rec.ass_attribute29;
          l_asg_rec.ass_attribute30 := l_primary_asg_rec.ass_attribute30;
        end if;
        --
        if (l_asg_rec.cagr_id_flex_num = l_primary_asg_rec.cagr_id_flex_num) then
          l_cag_rec.segment1  := NVL(l_cag_rec.segment1, l_primary_cag_rec.segment1);
          l_cag_rec.segment2  := NVL(l_cag_rec.segment2, l_primary_cag_rec.segment2);
          l_cag_rec.segment3  := NVL(l_cag_rec.segment3, l_primary_cag_rec.segment3);
          l_cag_rec.segment4  := NVL(l_cag_rec.segment4, l_primary_cag_rec.segment4);
          l_cag_rec.segment5  := NVL(l_cag_rec.segment5, l_primary_cag_rec.segment5);
          l_cag_rec.segment6  := NVL(l_cag_rec.segment6, l_primary_cag_rec.segment6);
          l_cag_rec.segment7  := NVL(l_cag_rec.segment7, l_primary_cag_rec.segment7);
          l_cag_rec.segment8  := NVL(l_cag_rec.segment8, l_primary_cag_rec.segment8);
          l_cag_rec.segment9  := NVL(l_cag_rec.segment9, l_primary_cag_rec.segment9);
          l_cag_rec.segment10 := NVL(l_cag_rec.segment10,l_primary_cag_rec.segment10);
          l_cag_rec.segment11 := NVL(l_cag_rec.segment11,l_primary_cag_rec.segment11);
          l_cag_rec.segment12 := NVL(l_cag_rec.segment12,l_primary_cag_rec.segment12);
          l_cag_rec.segment13 := NVL(l_cag_rec.segment13,l_primary_cag_rec.segment13);
          l_cag_rec.segment14 := NVL(l_cag_rec.segment14,l_primary_cag_rec.segment14);
          l_cag_rec.segment15 := NVL(l_cag_rec.segment15,l_primary_cag_rec.segment15);
          l_cag_rec.segment16 := NVL(l_cag_rec.segment16,l_primary_cag_rec.segment16);
          l_cag_rec.segment17 := NVL(l_cag_rec.segment17,l_primary_cag_rec.segment17);
          l_cag_rec.segment18 := NVL(l_cag_rec.segment18,l_primary_cag_rec.segment18);
          l_cag_rec.segment19 := NVL(l_cag_rec.segment19,l_primary_cag_rec.segment19);
          l_cag_rec.segment20 := NVL(l_cag_rec.segment20,l_primary_cag_rec.segment20);
       elsif (l_asg_rec.cagr_id_flex_num is null) then
          l_asg_rec.cagr_id_flex_num := l_primary_asg_rec.cagr_id_flex_num;
          l_cag_rec.segment1  := l_primary_cag_rec.segment1;
          l_cag_rec.segment2  := l_primary_cag_rec.segment2;
          l_cag_rec.segment3  := l_primary_cag_rec.segment3;
          l_cag_rec.segment4  := l_primary_cag_rec.segment4;
          l_cag_rec.segment5  := l_primary_cag_rec.segment5;
          l_cag_rec.segment6  := l_primary_cag_rec.segment6;
          l_cag_rec.segment7  := l_primary_cag_rec.segment7;
          l_cag_rec.segment8  := l_primary_cag_rec.segment8;
          l_cag_rec.segment9  := l_primary_cag_rec.segment9;
          l_cag_rec.segment10 := l_primary_cag_rec.segment10;
          l_cag_rec.segment11 := l_primary_cag_rec.segment11;
          l_cag_rec.segment12 := l_primary_cag_rec.segment12;
          l_cag_rec.segment13 := l_primary_cag_rec.segment13;
          l_cag_rec.segment14 := l_primary_cag_rec.segment14;
          l_cag_rec.segment15 := l_primary_cag_rec.segment15;
          l_cag_rec.segment16 := l_primary_cag_rec.segment16;
          l_cag_rec.segment17 := l_primary_cag_rec.segment17;
          l_cag_rec.segment18 := l_primary_cag_rec.segment18;
          l_cag_rec.segment19 := l_primary_cag_rec.segment19;
          l_cag_rec.segment20 := l_primary_cag_rec.segment20;
        end if;
        --
        l_scl_rec.segment1  := NVL(l_scl_rec.segment1, l_primary_scl_rec.segment1);
        l_scl_rec.segment2  := NVL(l_scl_rec.segment2, l_primary_scl_rec.segment2);
        l_scl_rec.segment3  := NVL(l_scl_rec.segment3, l_primary_scl_rec.segment3);
        l_scl_rec.segment4  := NVL(l_scl_rec.segment4, l_primary_scl_rec.segment4);
        l_scl_rec.segment5  := NVL(l_scl_rec.segment5, l_primary_scl_rec.segment5);
        l_scl_rec.segment6  := NVL(l_scl_rec.segment6, l_primary_scl_rec.segment6);
        l_scl_rec.segment7  := NVL(l_scl_rec.segment7, l_primary_scl_rec.segment7);
        l_scl_rec.segment8  := NVL(l_scl_rec.segment8, l_primary_scl_rec.segment8);
        l_scl_rec.segment9  := NVL(l_scl_rec.segment9, l_primary_scl_rec.segment9);
        l_scl_rec.segment10 := NVL(l_scl_rec.segment10,l_primary_scl_rec.segment10);
        l_scl_rec.segment11 := NVL(l_scl_rec.segment11,l_primary_scl_rec.segment11);
        l_scl_rec.segment12 := NVL(l_scl_rec.segment12,l_primary_scl_rec.segment12);
        l_scl_rec.segment13 := NVL(l_scl_rec.segment13,l_primary_scl_rec.segment13);
        l_scl_rec.segment14 := NVL(l_scl_rec.segment14,l_primary_scl_rec.segment14);
        l_scl_rec.segment15 := NVL(l_scl_rec.segment15,l_primary_scl_rec.segment15);
        l_scl_rec.segment16 := NVL(l_scl_rec.segment16,l_primary_scl_rec.segment16);
        l_scl_rec.segment17 := NVL(l_scl_rec.segment17,l_primary_scl_rec.segment17);
        l_scl_rec.segment18 := NVL(l_scl_rec.segment18,l_primary_scl_rec.segment18);
        l_scl_rec.segment19 := NVL(l_scl_rec.segment19,l_primary_scl_rec.segment19);
        l_scl_rec.segment20 := NVL(l_scl_rec.segment20,l_primary_scl_rec.segment20);
        l_scl_rec.segment21 := NVL(l_scl_rec.segment21,l_primary_scl_rec.segment21);
        l_scl_rec.segment22 := NVL(l_scl_rec.segment22,l_primary_scl_rec.segment22);
        l_scl_rec.segment23 := NVL(l_scl_rec.segment23,l_primary_scl_rec.segment23);
        l_scl_rec.segment24 := NVL(l_scl_rec.segment24,l_primary_scl_rec.segment24);
        l_scl_rec.segment25 := NVL(l_scl_rec.segment25,l_primary_scl_rec.segment25);
        l_scl_rec.segment26 := NVL(l_scl_rec.segment26,l_primary_scl_rec.segment26);
        l_scl_rec.segment27 := NVL(l_scl_rec.segment27,l_primary_scl_rec.segment27);
        l_scl_rec.segment28 := NVL(l_scl_rec.segment28,l_primary_scl_rec.segment28);
        l_scl_rec.segment29 := NVL(l_scl_rec.segment29,l_primary_scl_rec.segment29);
        l_scl_rec.segment30 := NVL(l_scl_rec.segment30,l_primary_scl_rec.segment30);
        --
      end if;
      --
       --The below call to the old update_emp_asg_criteria procedure has been commented as per bug 5102160
      -- soft_coding_keyflex_id is passed by calling the new update_emp_asg_criteria procedure

     /* hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_dummy
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      );*/

	p_asg_rec := l_asg_rec;

      hr_assignment_api.update_emp_asg_criteria
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => l_datetrack_update_mode
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_grade_id                     => l_asg_rec.grade_id
      ,p_position_id                  => l_asg_rec.position_id
      ,p_job_id                       => l_asg_rec.job_id
      ,p_payroll_id                   => l_asg_rec.payroll_id
      ,p_location_id                  => l_asg_rec.location_id
      ,p_special_ceiling_step_id      => l_asg_rec.special_ceiling_step_id
      ,p_organization_id              => l_asg_rec.organization_id
      ,p_pay_basis_id                 => l_asg_rec.pay_basis_id
      ,p_segment1                     => l_pgp_rec.segment1
      ,p_segment2                     => l_pgp_rec.segment2
      ,p_segment3                     => l_pgp_rec.segment3
      ,p_segment4                     => l_pgp_rec.segment4
      ,p_segment5                     => l_pgp_rec.segment5
      ,p_segment6                     => l_pgp_rec.segment6
      ,p_segment7                     => l_pgp_rec.segment7
      ,p_segment8                     => l_pgp_rec.segment8
      ,p_segment9                     => l_pgp_rec.segment9
      ,p_segment10                    => l_pgp_rec.segment10
      ,p_segment11                    => l_pgp_rec.segment11
      ,p_segment12                    => l_pgp_rec.segment12
      ,p_segment13                    => l_pgp_rec.segment13
      ,p_segment14                    => l_pgp_rec.segment14
      ,p_segment15                    => l_pgp_rec.segment15
      ,p_segment16                    => l_pgp_rec.segment16
      ,p_segment17                    => l_pgp_rec.segment17
      ,p_segment18                    => l_pgp_rec.segment18
      ,p_segment19                    => l_pgp_rec.segment19
      ,p_segment20                    => l_pgp_rec.segment20
      ,p_segment21                    => l_pgp_rec.segment21
      ,p_segment22                    => l_pgp_rec.segment22
      ,p_segment23                    => l_pgp_rec.segment23
      ,p_segment24                    => l_pgp_rec.segment24
      ,p_segment25                    => l_pgp_rec.segment25
      ,p_segment26                    => l_pgp_rec.segment26
      ,p_segment27                    => l_pgp_rec.segment27
      ,p_segment28                    => l_pgp_rec.segment28
      ,p_segment29                    => l_pgp_rec.segment29
      ,p_segment30                    => l_pgp_rec.segment30
      ,p_employment_category          => l_asg_rec.employment_category
      ,p_people_group_id              => l_dummy
      ,p_soft_coding_keyflex_id       => l_asg_rec.soft_coding_keyflex_id
      ,p_group_name                   => l_dummyv
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_org_now_no_manager_warning   => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_spp_delete_warning           => l_dummyb
      ,p_entries_changed_warning      => l_dummyv
      ,p_tax_district_changed_warning => l_dummyb
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug 2999562
      );
      --
   p_asg_rec.people_group_id := l_dummy;

      hr_utility.set_location(l_proc, 340);
      --
      hr_assignment_api.update_emp_asg
      (p_validate                     => FALSE
      ,p_effective_date               => l_hire_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => l_primary_asg_id
      ,p_object_version_number        => l_primary_ovn
      ,p_supervisor_id                => l_asg_rec.supervisor_id
      ,p_assignment_number            => l_asg_rec.assignment_number
      ,p_change_reason                => l_asg_rec.change_reason
      ,p_date_probation_end           => l_asg_rec.date_probation_end
      ,p_default_code_comb_id         => l_asg_rec.default_code_comb_id
      ,p_frequency                    => l_asg_rec.frequency
      ,p_internal_address_line        => l_asg_rec.internal_address_line
      ,p_manager_flag                 => l_asg_rec.manager_flag
      ,p_normal_hours                 => l_asg_rec.normal_hours
      ,p_perf_review_period           => l_asg_rec.perf_review_period
      ,p_perf_review_period_frequency => l_asg_rec.perf_review_period_frequency
      ,p_probation_period             => l_asg_rec.probation_period
      ,p_probation_unit               => l_asg_rec.probation_unit
      ,p_sal_review_period            => l_asg_rec.sal_review_period
      ,p_sal_review_period_frequency  => l_asg_rec.sal_review_period_frequency
      ,p_set_of_books_id              => l_asg_rec.set_of_books_id
      ,p_source_type                  => l_asg_rec.source_type
      ,p_time_normal_finish           => l_asg_rec.time_normal_finish
      ,p_time_normal_start            => l_asg_rec.time_normal_start
      ,p_bargaining_unit_code         => l_asg_rec.bargaining_unit_code
      ,p_labour_union_member_flag     => l_asg_rec.labour_union_member_flag
      ,p_hourly_salaried_code         => l_asg_rec.hourly_salaried_code
      ,p_ass_attribute_category       => l_asg_rec.ass_attribute_category
      ,p_ass_attribute1               => l_asg_rec.ass_attribute1
      ,p_ass_attribute2               => l_asg_rec.ass_attribute2
      ,p_ass_attribute3               => l_asg_rec.ass_attribute3
      ,p_ass_attribute4               => l_asg_rec.ass_attribute4
      ,p_ass_attribute5               => l_asg_rec.ass_attribute5
      ,p_ass_attribute6               => l_asg_rec.ass_attribute6
      ,p_ass_attribute7               => l_asg_rec.ass_attribute7
      ,p_ass_attribute8               => l_asg_rec.ass_attribute8
      ,p_ass_attribute9               => l_asg_rec.ass_attribute9
      ,p_ass_attribute10              => l_asg_rec.ass_attribute10
      ,p_ass_attribute11              => l_asg_rec.ass_attribute11
      ,p_ass_attribute12              => l_asg_rec.ass_attribute12
      ,p_ass_attribute13              => l_asg_rec.ass_attribute13
      ,p_ass_attribute14              => l_asg_rec.ass_attribute14
      ,p_ass_attribute15              => l_asg_rec.ass_attribute15
      ,p_ass_attribute16              => l_asg_rec.ass_attribute16
      ,p_ass_attribute17              => l_asg_rec.ass_attribute17
      ,p_ass_attribute18              => l_asg_rec.ass_attribute18
      ,p_ass_attribute19              => l_asg_rec.ass_attribute19
      ,p_ass_attribute20              => l_asg_rec.ass_attribute20
      ,p_ass_attribute21              => l_asg_rec.ass_attribute21
      ,p_ass_attribute22              => l_asg_rec.ass_attribute22
      ,p_ass_attribute23              => l_asg_rec.ass_attribute23
      ,p_ass_attribute24              => l_asg_rec.ass_attribute24
      ,p_ass_attribute25              => l_asg_rec.ass_attribute25
      ,p_ass_attribute26              => l_asg_rec.ass_attribute26
      ,p_ass_attribute27              => l_asg_rec.ass_attribute27
      ,p_ass_attribute28              => l_asg_rec.ass_attribute28
      ,p_ass_attribute29              => l_asg_rec.ass_attribute29
      ,p_ass_attribute30              => l_asg_rec.ass_attribute30
      ,p_segment1                     => l_scl_rec.segment1
      ,p_segment2                     => l_scl_rec.segment2
      ,p_segment3                     => l_scl_rec.segment3
      ,p_segment4                     => l_scl_rec.segment4
      ,p_segment5                     => l_scl_rec.segment5
      ,p_segment6                     => l_scl_rec.segment6
      ,p_segment7                     => l_scl_rec.segment7
      ,p_segment8                     => l_scl_rec.segment8
      ,p_segment9                     => l_scl_rec.segment9
      ,p_segment10                    => l_scl_rec.segment10
      ,p_segment11                    => l_scl_rec.segment11
      ,p_segment12                    => l_scl_rec.segment12
      ,p_segment13                    => l_scl_rec.segment13
      ,p_segment14                    => l_scl_rec.segment14
      ,p_segment15                    => l_scl_rec.segment15
      ,p_segment16                    => l_scl_rec.segment16
      ,p_segment17                    => l_scl_rec.segment17
      ,p_segment18                    => l_scl_rec.segment18
      ,p_segment19                    => l_scl_rec.segment19
      ,p_segment20                    => l_scl_rec.segment20
      ,p_segment21                    => l_scl_rec.segment21
      ,p_segment22                    => l_scl_rec.segment22
      ,p_segment23                    => l_scl_rec.segment23
      ,p_segment24                    => l_scl_rec.segment24
      ,p_segment25                    => l_scl_rec.segment25
      ,p_segment26                    => l_scl_rec.segment26
      ,p_segment27                    => l_scl_rec.segment27
      ,p_segment28                    => l_scl_rec.segment28
      ,p_segment29                    => l_scl_rec.segment29
      ,p_segment30                    => l_scl_rec.segment30
      ,p_contract_id                  => l_asg_rec.contract_id
      ,p_establishment_id             => l_asg_rec.establishment_id
      ,p_collective_agreement_id      => l_asg_rec.collective_agreement_id
      ,p_cagr_id_flex_num             => l_asg_rec.cagr_id_flex_num
      ,p_cag_segment1                 => l_cag_rec.segment1
      ,p_cag_segment2                 => l_cag_rec.segment2
      ,p_cag_segment3                 => l_cag_rec.segment3
      ,p_cag_segment4                 => l_cag_rec.segment4
      ,p_cag_segment5                 => l_cag_rec.segment5
      ,p_cag_segment6                 => l_cag_rec.segment6
      ,p_cag_segment7                 => l_cag_rec.segment7
      ,p_cag_segment8                 => l_cag_rec.segment8
      ,p_cag_segment9                 => l_cag_rec.segment9
      ,p_cag_segment10                => l_cag_rec.segment10
      ,p_cag_segment11                => l_cag_rec.segment11
      ,p_cag_segment12                => l_cag_rec.segment12
      ,p_cag_segment13                => l_cag_rec.segment13
      ,p_cag_segment14                => l_cag_rec.segment14
      ,p_cag_segment15                => l_cag_rec.segment15
      ,p_cag_segment16                => l_cag_rec.segment16
      ,p_cag_segment17                => l_cag_rec.segment17
      ,p_cag_segment18                => l_cag_rec.segment18
      ,p_cag_segment19                => l_cag_rec.segment19
      ,p_cag_segment20                => l_cag_rec.segment20
      ,p_notice_period		      => l_asg_rec.notice_period
      ,p_notice_period_uom            => l_asg_rec.notice_period_uom
      ,p_employee_category            => l_asg_rec.employee_category
      ,p_work_at_home		      => l_asg_rec.work_at_home
      ,p_job_post_source_name	      => l_asg_rec.job_post_source_name
      ,p_cagr_grade_def_id            => l_dummynum1 -- Bug # 2788390 modified l_dummy to l_dummynum1.
      ,p_cagr_concatenated_segments   => l_dummyv
      ,p_concatenated_segments        => l_dummyv
      ,p_soft_coding_keyflex_id       => l_dummy1
      ,p_comment_id                   => l_dummy2
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_no_managers_warning          => l_dummyb
      ,p_other_manager_warning        => l_dummyb
      ,p_hourly_salaried_warning      => l_dummyb
      );
      --
   p_asg_rec.soft_coding_keyflex_id := l_dummy1;

      hr_utility.set_location(l_proc, 350);


--Fix For Bug # 5987409 Starts -----

UPDATE PER_ASSIGNMENTS_F PAF SET PAF.VACANCY_ID =l_asg_rec.vacancy_id ,
PAF.RECRUITER_ID =l_asg_rec.recruiter_id
WHERE  PAF.ASSIGNMENT_ID = l_primary_asg_id AND
PAF.EFFECTIVE_START_DATE = l_effective_start_date AND
PAF.EFFECTIVE_END_DATE = l_effective_end_date;

--Fix For Bug # 5987409 Starts -----


      --
      -- now end date the application
      --
      per_asg_del.del
      (p_assignment_id              => l_asg_rec.assignment_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_business_group_id          => l_business_group_id
      ,p_object_version_number	    => l_asg_rec.object_version_number
      ,p_effective_date             => l_hire_date-1
      ,p_validation_start_date      => l_validation_start_date
      ,p_validation_end_date        => l_validation_end_date
      ,p_datetrack_mode             => 'DELETE'
      ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
      --
      hr_utility.set_location(l_proc, 360);
      --
       -- added for the bug 4641965
      --
       if (p_primary_assignment_id is not null ) then
       l_pspl_asg_id :=p_primary_assignment_id;
       else
       l_pspl_asg_id :=asg_rec.assignment_id;
       end if;
        --start of bug 5102289
	 open get_primary_pay_basis(l_primary_asg_id);
         fetch get_primary_pay_basis into l_pay_basis_id;
         if l_pay_basis_id = l_asg_rec.pay_basis_id then
           l_approved := 'N';
         else
           l_approved := 'Y';
         end if;
         close get_primary_pay_basis;
  	--End of bug 5102289

       OPEN get_pay_proposal(l_pspl_asg_id);
       FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date,l_proposal_reason; --Added Proposal_Reason For Bug # 5987409 --
       if get_pay_proposal%found then
           /*  l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
            open get_primary_proposal (l_primary_asg_id);
            fetch get_primary_proposal into l_pay_pspl_id,l_pay_obj_number;
              if get_primary_proposal%found then
                 close get_primary_proposal; */
              update per_pay_proposals set assignment_id = l_primary_asg_id
                                                       where pay_proposal_id = l_pay_pspl_id;
              l_pay_obj_number := l_pay_obj_number + 1;
                 hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id ,
             	        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => l_approved,
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);
           /*  else
	     close get_primary_proposal;
	     l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_pay_pspl_id,
                        p_assignment_id              => l_primary_asg_id,
                        p_object_version_number      => l_pay_obj_number,
                        p_change_date                => p_hire_date,
                        p_approved                   => l_approved,
                        p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                        p_proposed_salary_warning    => l_proposed_salary_warning,
                        p_approved_warning	     => l_approved_warning,
                        p_payroll_warning	     => l_payroll_warning,
                        p_proposed_salary_n          => l_proposed_sal_n,
                        p_business_group_id          => l_business_group_id,
                        p_proposal_reason            => l_proposal_reason);

             end if; */
	--
      end if;
     --
        close get_pay_proposal;
     --
     -- end of bug 4641965
    end if;
    --
--Bug 4959033

   open get_business_group(l_primary_asg_id);
   fetch get_business_group into l_bg_id;
  --
   if get_business_group%NOTFOUND then
      close get_business_group;
      l_bg_id := hr_general.get_business_group_id;
   else
      close get_business_group;
   end if;
   --
    hrentmnt.maintain_entries_asg (
    p_assignment_id         => l_primary_asg_id,
    p_business_group_id     => l_bg_id,
    p_operation             => 'ASG_CRITERIA',
    p_actual_term_date      => null,
    p_last_standard_date    => null,
    p_final_process_date    => null,
    p_dt_mode               => 'UPDATE',
    p_validation_start_date => l_effective_start_date,
    p_validation_end_date   => l_effective_end_date
   );
   -- End of Bug 4959033
    open csr_vacs(l_asg_rec.vacancy_id);
    fetch csr_vacs into l_dummy;
    if csr_vacs%found then
      close csr_vacs;
      l_oversubscribed_vacancy_id :=l_asg_rec.vacancy_id;
    else
      close csr_vacs;
    end if;
    --
  end loop;
  --
  hr_utility.set_location(l_proc,370);
  --
  -- Maintain person type usage record
  --
-- PTU : Commented call to maintain_ptu

--  hr_per_type_usage_internal.maintain_ptu
--    (p_person_id                   => p_person_id
--    ,p_action                      => 'TERM_APL'
--    ,p_business_group_id           => l_business_group_id
--    ,p_actual_termination_date     => l_hire_date
--    );
  --
  -- Call After Process User Hook for hire_employee_applicant
  --
  begin
    hr_employee_applicant_bk2.hire_employee_applicant_a
      (
       p_hire_date                  => l_hire_date,
       p_person_id                  => p_person_id,
       p_primary_assignment_id      => p_primary_assignment_id,
       p_overwrite_primary          => p_overwrite_primary,
       p_person_type_id             => p_person_type_id,
       p_per_object_version_number  => l_per_object_version_number,
       p_per_effective_start_date   => l_per_effective_start_date,
       p_per_effective_end_date     => l_per_effective_end_date,
       p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning,
       p_assign_payroll_warning     => l_assign_payroll_warning,
       p_oversubscribed_vacancy_id  => l_oversubscribed_vacancy_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_EMPLOYEE_APPLICANT'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for hire_employee_applicant
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    -- Set OUT parameters
    --
    p_per_object_version_number    := l_per_object_version_number;
    p_per_effective_start_date     := l_per_effective_start_date;
    p_per_effective_end_date       := l_per_effective_end_date;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 380);
    --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO hire_employee_applicant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Set OUT parameters to null
    --
    p_per_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id ;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 390);
   --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_per_object_version_number    := l_ovn;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_oversubscribed_vacancy_id    := null;
    p_unaccepted_asg_del_warning   := false;
    p_assign_payroll_warning       := false;
    ROLLBACK TO hire_employee_applicant;
    --
    --
    -- set in out parameters and set out parameters
    --

    hr_utility.set_location(' Leaving:'||l_proc, 400);
    raise;
    --
end hire_employee_applicant;
END hr_employee_applicant_api;

/
