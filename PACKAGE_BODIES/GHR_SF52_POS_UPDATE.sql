--------------------------------------------------------
--  DDL for Package Body GHR_SF52_POS_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_POS_UPDATE" AS
/* $Header: ghpauppo.pkb 115.13 2004/01/28 21:42:08 ajose ship $ */

g_package varchar2(32) := 'GHR_SF52_POS_UPDATE';


--
-- ---------------------------------------------------------------------------
-- |--------------------< retrieve_gov_kff_setup_info >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve government key flexfields setup information.
--
-- Prerequisites:
--   Data must be existed in organization information with
--      ORG_INFORMATION = 'GHR_US_ORG_INFORMATION'.
--
-- In Parameters:
--   p_business_group_id
--
-- Out Parameters:
--   p_org_info_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_gov_kff_setup_info
	(p_business_group_id    in     per_business_groups.business_group_id%type
	,p_org_info_rec         out nocopy   org_info_rec_type
	) is
  --
  l_proc                varchar2(72) := g_package||'retrieve_gov_kff_setup_info';
  l_org_info_id         hr_organization_information.org_information_id%type;
  l_org_info_found      boolean := FALSE;
  --
  cursor c_organization_information (org_id number) is
	select oi.org_information1,
	       oi.org_information2,
	       oi.org_information3,
	       oi.org_information4,
	       oi.org_information5
	  from hr_organization_information oi
	  where oi.organization_id = org_id
	  and oi.org_information_context = 'GHR_US_ORG_INFORMATION';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  p_org_info_rec.information1 := NULL;
  p_org_info_rec.information2 := NULL;
  p_org_info_rec.information3 := NULL;
  p_org_info_rec.information4 := NULL;
  p_org_info_rec.information5 := NULL;
  --
  for c_organization_information_rec in
		c_organization_information (p_business_group_id) loop
    l_org_info_found := TRUE;
    p_org_info_rec.information1 := c_organization_information_rec.org_information1;
    p_org_info_rec.information2 := c_organization_information_rec.org_information2;
    p_org_info_rec.information3 := c_organization_information_rec.org_information3;
    p_org_info_rec.information4 := c_organization_information_rec.org_information4;
    p_org_info_rec.information5 := c_organization_information_rec.org_information5;
    exit;
  end loop;
  if not l_org_info_found then
    -- hr_utility.set_message(8301, 'GHR_38025_API_INV_ORG');
    -- hr_utility.raise_error;
    null;
  end if;
  hr_utility.set_location(l_proc, 2);
  --
  if (p_org_info_rec.information1 is NULL
      and p_org_info_rec.information2 is NULL
      and p_org_info_rec.information3 is NULL
      and p_org_info_rec.information4 is NULL
      and p_org_info_rec.information5 is NULL) then
    -- hr_utility.set_message(8301, 'GHR_38033_API_ORG_DDF_NOT_EXST');
    -- hr_utility.raise_error;
    null;
  end if;
  --
   hr_utility.set_location(' Leaving:'||l_proc, 3);
--
exception
  when no_data_found then
    -- hr_utility.set_message(8301, 'GHR_38033_API_ORG_DDF_NOT_EXST');
    -- hr_utility.raise_error;
    null;

  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

       p_org_info_rec          := NULL;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

end retrieve_gov_kff_setup_info;

procedure update_position_info
(p_pos_data_rec    in position_data_rec_type
)
IS

l_proc              varchar2(25) := 'update_position_info';
l_datetrack_mode    VARCHAR2(20);

procedure  update_position_kff
IS
l_proc              varchar2(25) := 'update_position_kff';

 l_position_definition_id         hr_all_positions_f.position_definition_id%TYPE;
 l_position_name                  hr_all_positions_f.name%TYPE;
 l_organization_id                per_organization_units.organization_id%TYPE;
 l_business_group_id              number;
 l_object_version_number          number;
 l_valid_grades_changed_warning   BOOLEAN;
 l_agency_code_info_num           number(2);
 l_org_info_rec                   org_info_rec_type;
 l_segment_tab 		          segment_tab_type;
 l_effective_start_date           date;
 l_effective_end_date             date;


cursor c_get_position_details(c_position_id IN number)
IS

	SELECT name,position_definition_id,
               organization_id,object_version_number,business_group_id
        FROM   hr_all_positions_f  pos
        WHERE  position_id = c_position_id -- Venkat -- Position DT
        and    p_pos_data_rec.effective_date between
           pos.effective_start_date and pos.effective_end_date;


cursor c_get_segments(c_position_definition_id in number)
IS

	SELECT segment1,
               segment2,
	       segment3,
	       segment4,
	       segment5,
	       segment6,
	       segment7,
	       segment8,
	       segment9,
	       segment10,
	       segment11,
	       segment12,
	       segment13,
	       segment14,
	       segment15,
	       segment16,
	       segment17,
	       segment18,
	       segment19,
               segment20,
	       segment21,
	       segment22,
	       segment23,
	       segment24,
	       segment25,
	       segment26,
	       segment27,
	       segment28,
	       segment29,
	       segment30
     FROM      per_position_definitions
     WHERE     position_definition_id = c_position_definition_id;


BEGIN
hr_utility.set_location('Entering ' || l_proc ,5);
hr_utility.set_location('p_pos_data_rec.position_id  ' || to_char(p_pos_data_rec.position_id) ,6);
hr_utility.set_location('p_pos_data_rec.effective_date  ' || to_char(p_pos_data_rec.effective_date) ,7);

for c_position_detail_rec IN c_get_position_details(p_pos_data_rec.position_id) LOOP

    l_position_definition_id := c_position_detail_rec.position_definition_id;
    l_object_version_number  := c_position_detail_rec.object_version_number;
    --l_position_name          := c_position_detail_rec.name;
    l_organization_id        := c_position_detail_rec.organization_id;
    l_business_group_id      := c_position_detail_rec.business_group_id;
hr_utility.set_location('l_business_group_id ' || to_char(l_business_group_id) ,10);
end loop;

hr_utility.set_location('Entering ' || l_proc ,10);
for cursor_rec in c_get_segments(l_position_definition_id) LOOP

    l_segment_tab(1) := cursor_rec.segment1;
    l_segment_tab(2) := cursor_rec.segment2;
    l_segment_tab(3) := cursor_rec.segment3;
    l_segment_tab(4) := cursor_rec.segment4;
    l_segment_tab(5) := cursor_rec.segment5;
    l_segment_tab(6) := cursor_rec.segment6;
    l_segment_tab(7) := cursor_rec.segment7;
    l_segment_tab(8) := cursor_rec.segment8;
    l_segment_tab(9) := cursor_rec.segment9;
    l_segment_tab(10) := cursor_rec.segment10;
    l_segment_tab(11) := cursor_rec.segment11;
    l_segment_tab(12) := cursor_rec.segment12;
    l_segment_tab(13) := cursor_rec.segment13;
    l_segment_tab(14) := cursor_rec.segment14;
    l_segment_tab(15) := cursor_rec.segment15;
    l_segment_tab(16) := cursor_rec.segment16;
    l_segment_tab(17) := cursor_rec.segment17;
    l_segment_tab(18) := cursor_rec.segment18;
    l_segment_tab(19) := cursor_rec.segment19;
    l_segment_tab(20) := cursor_rec.segment20;
    l_segment_tab(21) := cursor_rec.segment21;
    l_segment_tab(22) := cursor_rec.segment22;
    l_segment_tab(23) := cursor_rec.segment23;
    l_segment_tab(24) := cursor_rec.segment24;
    l_segment_tab(25) := cursor_rec.segment25;
    l_segment_tab(26) := cursor_rec.segment26;
    l_segment_tab(27) := cursor_rec.segment27;
    l_segment_tab(28) := cursor_rec.segment28;
    l_segment_tab(29) := cursor_rec.segment29;
    l_segment_tab(30) := cursor_rec.segment30;

END LOOP;

hr_utility.set_location('bg id :' || to_char(l_business_group_id) ,15);
     retrieve_gov_kff_setup_info (p_business_group_id    => l_business_group_id
                                  ,p_org_info_rec          => l_org_info_rec);

hr_utility.set_location('org_info_rec :' || l_org_info_rec.information5,15);
     l_agency_code_info_num := to_number(substr(l_org_info_rec.information5,8));
hr_utility.set_location('l_agency_code_info_num :' || to_char(l_agency_code_info_num),15);


     l_segment_tab(l_agency_code_info_num) :=
                            p_pos_data_rec.agency_code_subelement;

    hr_utility.set_location('after l_segment_tab ' || l_proc ,20);
    l_datetrack_mode := pos_return_update_mode
                 (p_position_id        => p_pos_data_rec.position_id,
                  p_effective_date     => p_pos_data_rec.effective_date);
     hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_mode,25);
     hr_position_api.update_position(
 	       p_position_id              => p_pos_data_rec.position_id,
               p_object_version_number    => l_object_version_number ,
               p_segment1                 => l_segment_tab(1),
               p_segment2                 => l_segment_tab(2),
	       p_segment3                 => l_segment_tab(3),
	       p_segment4                 => l_segment_tab(4),
	       p_segment5                 => l_segment_tab(5),
	       p_segment6                 => l_segment_tab(6),
	       p_segment7                 => l_segment_tab(7),
	       p_segment8                 => l_segment_tab(8),
	       p_segment9                 => l_segment_tab(9),
	       p_segment10                 => l_segment_tab(10),
	       p_segment11                 => l_segment_tab(11),
	       p_segment12                 => l_segment_tab(12),
	       p_segment13                 => l_segment_tab(13),
	       p_segment14                 => l_segment_tab(14),
	       p_segment15                 => l_segment_tab(15),
	       p_segment16                 => l_segment_tab(16),
	       p_segment17                 => l_segment_tab(17),
	       p_segment18                 => l_segment_tab(18),
	       p_segment19                 => l_segment_tab(19),
	       p_segment20                 => l_segment_tab(20),
	       p_segment21                 => l_segment_tab(21),
	       p_segment22                 => l_segment_tab(22),
	       p_segment23                 => l_segment_tab(23),
	       p_segment24                 => l_segment_tab(24),
	       p_segment25                 => l_segment_tab(25),
	       p_segment26                 => l_segment_tab(26),
	       p_segment27                 => l_segment_tab(27),
	       p_segment28                 => l_segment_tab(28),
	       p_segment29                 => l_segment_tab(29),
	       p_segment30                 => l_segment_tab(30),
               p_position_definition_id    => l_position_definition_id,
               p_name                      => l_position_name,
               p_valid_grades_changed_warning => l_valid_grades_changed_warning,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_effective_date           => p_pos_data_rec.effective_date,
               p_datetrack_mode           => l_datetrack_mode);

hr_utility.set_location('after update_position_api ' || l_proc ,25);

end;

procedure update_pos_organization
IS

l_object_version_number  number;
l_position_definition_id hr_all_positions_f.position_definition_id%TYPE;
l_pos_name               hr_all_positions_f.name%TYPE;
l_valid_grade_warning    boolean;
l_effective_start_date   date;
l_effective_end_date     date;
l_location_id            hr_all_positions_f.location_id%TYPE;

cursor c_get_position_details(c_position_id IN number)
IS

	SELECT name,position_definition_id,
               organization_id,object_version_number,business_group_id
	       ,location_id --  Bug 3219207 added by Ashley
        FROM   hr_all_positions_f  pos
        WHERE  position_id = c_position_id -- Venkat -- Position DT
        and    p_pos_data_rec.effective_date between
           pos.effective_start_date and pos.effective_end_date;


BEGIN



    hr_utility.set_location('update_pos_organization   ' ,25);

  FOR c_get_position_detail_rec IN c_get_position_details(p_pos_data_rec.position_id) LOOP
    l_object_version_number   := c_get_position_detail_rec.object_version_number;
    l_position_definition_id  := c_get_position_detail_rec.position_definition_id;
    l_location_id             := c_get_position_detail_rec.location_id; -- Bug 3219207


    l_datetrack_mode := pos_return_update_mode
                 (p_position_id        => p_pos_data_rec.position_id,
                  p_effective_date     => p_pos_data_rec.effective_date);

    hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_mode,25);


    IF p_pos_data_rec.location_id is not null THEN

       hr_position_api.update_position(
 	       p_position_id              => p_pos_data_rec.position_id,
               p_object_version_number    => l_object_version_number ,
               p_location_id              => p_pos_data_rec.location_id,
               p_position_definition_id   => l_position_definition_id,
               p_name                     => l_pos_name,
               p_valid_grades_changed_warning => l_valid_grade_warning,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_effective_date           => p_pos_data_rec.effective_date,
               p_datetrack_mode           => l_datetrack_mode);

      UPDATE hr_all_positions_f
      SET organization_id = p_pos_data_rec.organization_id
      WHERE position_id = p_pos_data_rec.position_id
      AND   effective_start_date = l_effective_start_date;

   ELSE

--Added this call for bug 3219207

       hr_position_api.update_position(
 	       p_position_id              => p_pos_data_rec.position_id,
               p_object_version_number    => l_object_version_number ,
               p_location_id              => l_location_id,
               p_position_definition_id   => l_position_definition_id,
               p_name                     => l_pos_name,
               p_valid_grades_changed_warning => l_valid_grade_warning,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_effective_date           => p_pos_data_rec.effective_date,
               p_datetrack_mode           => l_datetrack_mode
	                            );

      UPDATE hr_all_positions_f
      SET organization_id = p_pos_data_rec.organization_id
      WHERE position_id = p_pos_data_rec.position_id
      AND   effective_start_date = l_effective_start_date;

    END IF;

  END LOOP;

END;

procedure update_pos_end_date
IS

cursor c_get_position_details(c_position_id IN number, c_effective_date date)
IS
	SELECT  name,position_definition_id,
                organization_id,object_version_number,business_group_id
        FROM    hr_all_positions_f
        WHERE   position_id = c_position_id
        AND     nvl(c_effective_date,sysdate)
        between effective_start_date and effective_end_Date;

        Cursor c_position_status is
        SELECT shared_type_id,shared_type_name  from per_shared_types
        WHERE  system_type_cd = 'ELIMINATED';

  l_object_version_number  number;
  l_position_definition_id hr_all_positions_f.position_definition_id%TYPE;
  l_pos_name               hr_all_positions_f.name%TYPE;
  l_valid_grade_warning    boolean;
  l_location_id            hr_all_positions_f.location_id%TYPE;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_shared_type_id         number;

BEGIN
  hr_utility.set_location('update_pos_end_date ', 25);
 for c_get_position_details_rec in c_get_position_details (p_pos_data_rec.position_id , p_pos_data_rec.effective_date)   loop
     for c_position_status_rec in c_position_status loop
       l_shared_type_id :=   c_position_status_rec.shared_type_id;
       exit;
     end loop;

    l_datetrack_mode := pos_return_update_mode
                 (p_position_id        => p_pos_data_rec.position_id,
                  p_effective_date     => p_pos_data_rec.effective_date);
    hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_mode,25);
    hr_position_api.update_position(
 	       p_position_id              => p_pos_data_rec.position_id,
               p_object_version_number    => c_get_position_details_rec.object_version_number,
               p_position_definition_id   => c_get_position_details_rec.position_definition_id,
               p_name                     => l_pos_name,
               --p_date_end                 => p_pos_data_rec.effective_date,
               p_availability_status_id   =>  l_shared_type_id,
               p_valid_grades_changed_warning => l_valid_grade_warning,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_effective_date           => p_pos_data_rec.effective_date,
               p_datetrack_mode           => l_datetrack_mode);
       hr_utility.set_location('After update of position',1);


     --UPDATE hr_all_positions_f
     --SET date_end = p_pos_data_rec.effective_end_date
     --WHERE position_id = p_pos_data_rec.position_id
     --AND   effective_start_date = p_pos_data_rec.effective_date;

 END LOOP;

END;

procedure update_pos_job_id
IS
l_effective_start_Date date;
l_effective_end_Date date;
l_pos_name               hr_all_positions_f.name%type;
l_position_Definition_id hr_all_positions_f.position_Definition_id%type;
l_object_version_number number;
l_valid_grade_warning boolean;

cursor c_get_position_details(c_position_id IN number,c_effective_date date)
IS

	SELECT name,position_definition_id,
               job_id,object_version_number,business_group_id
        FROM   hr_all_positions_f
        WHERE  position_id = c_position_id
        and    nvl(c_effective_date,sysdate) between
               effective_start_date and effective_end_date;

BEGIN

    hr_utility.set_location('update_pos_job_id   ' ,25);
  FOR c_get_position_detail_rec IN c_get_position_details(p_pos_data_rec.position_id,p_pos_data_rec.effective_date) LOOP
   l_object_version_number :=  c_get_position_detail_rec.object_version_number;
   l_position_definition_id :=  c_get_position_detail_rec.position_definition_id;
    l_datetrack_mode := pos_return_update_mode
                 (p_position_id        => p_pos_data_rec.position_id,
                  p_effective_date     => p_pos_data_rec.effective_date);
    hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_mode,25);
    hr_position_api.update_position(
 	       p_position_id              => p_pos_data_rec.position_id,
               p_object_version_number    => l_object_version_number ,
               p_position_definition_id   => l_position_definition_id,
               p_name                     => l_pos_name,
               p_valid_grades_changed_warning => l_valid_grade_warning,
               p_effective_start_date     => l_effective_start_date,
               p_effective_end_date       => l_effective_end_date,
               p_effective_date           => p_pos_data_rec.effective_date,
               p_datetrack_mode           => l_datetrack_mode);

      UPDATE hr_all_positions_f
      SET job_id        = p_pos_data_rec.job_id
      WHERE position_id = p_pos_data_rec.position_id
      and effective_start_date = l_effective_start_date;


 END LOOP;

END;


BEGIN

IF p_pos_data_rec.organization_id is NOT NULL THEN

begin

   update_pos_organization;
exception
   when others then
      raise;
end;

END IF;

IF p_pos_data_rec.agency_code_subelement is NOT NULL
THEN

begin
    update_position_kff;
exception
   when others then
      raise;
end;

END IF;

IF p_pos_data_rec.effective_end_date is NOT NULL
THEN

begin
   update_pos_end_date;
exception
   when others then
      raise;
end;

END IF;

IF p_pos_data_rec.job_id is NOT NULL
THEN

begin
   update_pos_job_id;
exception
   when others then
      raise;
end;

END IF;

END;

FUNCTION pos_return_update_mode
  (p_position_id     IN     hr_all_positions_f.position_id%type,
   p_effective_date  IN     date)

RETURN varchar2 is

  l_proc     varchar2(72) := 'return_update_mode';
  l_eed      date;
  l_esd      date;
  l_mode     varchar2(20) := 'CORRECTION';
  l_exists  boolean := FALSE;

  cursor     c_update_mode_pos is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = p_position_id
    and      p_effective_date
    between  pos.effective_start_date
    and      pos.effective_end_date;

  cursor     c_update_mode_pos1 is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = p_position_id
    and      p_effective_date  <  pos.effective_start_date;

  Begin
    hr_utility.set_location('Entering  ' || l_proc,5);
      for update_mode in c_update_mode_pos loop
        hr_utility.set_location(l_proc,10);
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      If l_esd = p_effective_date then
        hr_utility.set_location(l_proc,20);
        l_mode := 'CORRECTION';
      Elsif l_esd < p_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
        hr_utility.set_location(l_proc,25);
        l_mode := 'UPDATE';                           --  to end date a row and then create a new row
      Elsif  l_esd <  p_effective_date  then
        hr_utility.set_location(l_proc,30);
        for update_mode1 in c_update_mode_pos1 loop
          hr_utility.set_location(l_proc,35);
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          hr_utility.set_location(l_proc,40);
          l_mode := 'UPDATE_CHANGE_INSERT';              -- to insert a row between 2 existing rows
        Else
          hr_utility.set_location(l_proc,45);
          l_mode := 'CORRECTION';
        End if;
        hr_utility.set_location(l_proc,50);
      End if;
      hr_utility.set_location(l_proc,55);
      hr_utility.set_location('UPDATE_MODE  :   ' || l_mode,2);
      If l_mode is null then
        hr_utility.set_message(8301,'GHR_GET_DATE_TRACK_FAILED');
        hr_utility.set_message_token('TABLE_NAME','HR_ALL_POSITIONS_F');
        hr_utility.raise_error;
      End if;
    return l_mode;
    hr_utility.set_location('Leaving ' ||l_proc,60);
End pos_return_update_mode;

-----
-- JH Added for bug 773795, Position's location is now updated with update to HR.
-----
PROCEDURE update_positions_location
 (p_position_id        IN       hr_all_positions_f.position_id%TYPE,
  p_location_id        IN       hr_all_positions_f.location_id%TYPE,
  p_effective_date     IN       date) IS

 l_position_definition_id         hr_all_positions_f.position_definition_id%TYPE;
 l_position_name                  hr_all_positions_f.name%TYPE;
 l_object_version_number          number;
 l_location_id                    hr_all_positions_f.location_id%TYPE;
 l_valid_grade_warning            BOOLEAN;
 l_effective_start_date           date;
 l_effective_end_date             date;
 l_datetrack_mode                 VARCHAR2(20);

cursor c_get_position_details
IS

	SELECT name, position_definition_id, location_id, object_version_number
      FROM   hr_all_positions_f
      WHERE  position_id = p_position_id
      and    nvl(p_effective_date,sysdate) between
             effective_start_date and effective_end_date;

BEGIN

  FOR c_get_position_detail_rec IN c_get_position_details LOOP
    l_position_name := c_get_position_detail_rec.name;
    l_position_definition_id := c_get_position_detail_rec.position_definition_id;
    l_location_id := c_get_position_detail_rec.location_id;
    l_object_version_number := c_get_position_detail_rec.object_version_number;

    If nvl(l_location_id,-1) <> nvl(p_location_id,-2) Then

      l_datetrack_mode := pos_return_update_mode
          (p_position_id        => p_position_id,
          p_effective_date     => p_effective_date);

      hr_utility.set_location('UPDATE_MODE Position  :   ' || l_datetrack_mode,99);

      hr_utility.set_location('update_pos_location ', 99);

      hr_position_api.update_position(
        p_position_id                  => p_position_id,
        p_object_version_number        => l_object_version_number,
        p_location_id                  => p_location_id,
        p_position_definition_id       => l_position_definition_id,
        p_name                         => l_position_name,
        p_valid_grades_changed_warning => l_valid_grade_warning,
        p_effective_start_date         => l_effective_start_date,
        p_effective_end_date           => l_effective_end_date,
        p_effective_date               => p_effective_date,
        p_datetrack_mode               => l_datetrack_mode);

      hr_utility.set_location('After update of positions location ',99);

    End If;

  END LOOP;

END;

end ghr_sf52_pos_update;


/
