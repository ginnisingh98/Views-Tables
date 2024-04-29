--------------------------------------------------------
--  DDL for Package Body GHR_DUTY_STATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_DUTY_STATION_API" as
/* $Header: ghdutapi.pkb 115.0 2003/06/19 08:42:19 vnarasim noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_duty_station_api.';

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_duty_station> >--------------------------|
-- ----------------------------------------------------------------------------
--

--Assumption : Create_duty_station is manipulated as create/update based on the existence of the record
--only where OVN = 1, else according to this logic a new rec. will be created.

procedure create_duty_station
  (p_validate                      in  boolean   default false
  ,p_duty_station_id 	           OUT nocopy number
  ,p_effective_start_date          out nocopy date
  ,p_effective_end_date            out nocopy date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2 default null
  ,p_name                          in  varchar2 default null
  ,p_duty_station_code             in  varchar2
  ,p_msa_code                      in  varchar2 default null
  ,p_cmsa_code                     in  varchar2 default null
  ,p_state_or_country_code         in  varchar2
  ,p_county_code                   in  varchar2 default null
  ,p_is_duty_station               in  varchar2 default 'Y'
  ,p_effective_date                in  date
  ,p_object_version_number         out nocopy number
  ) is
  --
  l_duty_station_id             ghr_duty_stations_f.duty_station_id%TYPE;
  l_proc                        varchar2(72) := g_package||'create_duty_stations';
  l_object_version_number       ghr_duty_stations_f.object_version_number%TYPE;
  l_effective_start_date date;
  l_effective_end_date   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_duty_stations;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_start_date := trunc(p_effective_start_date);
     l_effective_end_date   := trunc(p_effective_end_date);

  --
  begin
    --
    -- Start of API User Hook for the before hook of create_noac_remarks
    --
     ghr_duty_station_bk1.create_duty_station_b(
					   p_duty_station_id 	    =>   p_duty_station_id
					  ,p_effective_start_date   =>   p_effective_start_date
					  ,p_effective_end_date     =>   p_effective_end_date
					  ,p_locality_pay_area_id   =>   p_locality_pay_area_id
					  ,p_leo_pay_area_code      =>   p_leo_pay_area_code
					  ,p_name                   =>   p_name
					  ,p_duty_station_code      =>   p_duty_station_code
					  ,p_msa_code		    =>	 p_msa_code
					  ,p_cmsa_code              =>	 p_cmsa_code
					  ,p_state_or_country_code  =>   p_state_or_country_code
					  ,p_county_code	    =>	 p_county_code
					  ,p_is_duty_station	    =>   p_is_duty_station
					  ,p_effective_date         =>   trunc(p_effective_date)
					  ,p_object_version_number  =>   p_object_version_number
					);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_duty_stations'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_noac_remarks
    --
  end;
  --
  ghr_dut_ins.ins
  (
    p_duty_station_id        =>  l_duty_station_id
   ,p_effective_start_date   =>  l_effective_start_date
   ,p_effective_end_date     =>  l_effective_end_date
   ,p_locality_pay_area_id   =>  p_locality_pay_area_id
   ,p_leo_pay_area_code      =>  p_leo_pay_area_code
   ,p_name                   =>  p_name
   ,p_duty_station_code      =>  p_duty_station_code
   ,p_msa_code		     =>	 p_msa_code
   ,p_cmsa_code              =>	 p_cmsa_code
   ,p_state_or_country_code  =>  p_state_or_country_code
   ,p_county_code	     =>	 p_county_code
   ,p_is_duty_station	     =>  p_is_duty_station
   , p_object_version_number =>  p_object_version_number
   ,p_effective_date	     =>	 trunc(p_effective_date)
  );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_noac_remarks
    --
       ghr_duty_station_bk1.create_duty_station_a(
					   p_duty_station_id 	    =>   l_duty_station_id
				          ,p_effective_start_date   =>   l_effective_start_date
					  ,p_effective_end_date     =>   l_effective_end_date
					  ,p_locality_pay_area_id   =>   p_locality_pay_area_id
					  ,p_leo_pay_area_code      =>   p_leo_pay_area_code
					  ,p_name                   =>   p_name
					  ,p_duty_station_code      =>   p_duty_station_code
					  ,p_msa_code		    =>	 p_msa_code
					  ,p_cmsa_code              =>	 p_cmsa_code
					  ,p_state_or_country_code  =>   p_state_or_country_code
					  ,p_county_code	    =>	 p_county_code
					  ,p_is_duty_station	    =>   p_is_duty_station
					  ,p_effective_date         =>   trunc(p_effective_date)
					  ,p_object_version_number  =>   l_object_version_number
					);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_duty_stations'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_noac_remarks
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_duty_station_id       := l_duty_station_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_duty_stations;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   p_duty_station_id       := l_duty_station_id;
   p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_duty_stations;
    raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);

end create_duty_station;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<update_duty_station> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_duty_station
  (p_validate                      in     boolean  default false
  ,p_duty_station_id 	           in  number
  ,p_effective_start_date          out  nocopy date
  ,p_effective_end_date            out  nocopy date
  ,p_locality_pay_area_id          in  number
  ,p_leo_pay_area_code             in  varchar2 default hr_api.g_varchar2
  ,p_name                          in  varchar2 default hr_api.g_varchar2
  ,p_duty_station_code             in  varchar2
  ,p_msa_code                      in varchar2
  ,p_cmsa_code                     in varchar2
  ,p_state_or_country_code         in varchar2
  ,p_county_code                   in varchar2
  ,p_is_duty_station               in  varchar2 default hr_api.g_varchar2
  ,p_effective_date                in  date
  ,p_datetrack_update_mode	   in  varchar2
  ,p_object_version_number        IN out nocopy number
   )



is
  l_proc                varchar2(72) := g_package || 'update_duty_stations';
  l_effective_start_date  date;
  l_effective_end_date    date;
 l_object_version_number  ghr_duty_stations_f.object_version_number%TYPE;

begin

hr_utility.set_location('Entering:'|| l_proc, 5);
  --
    savepoint update_duty_stations;
  --
  -- Call Before Process User Hook
  --
  begin
   ghr_duty_station_bk2.update_duty_station_b
                                (  p_duty_station_id	    =>  p_duty_station_id
				  ,p_effective_start_date   =>  p_effective_start_date
				  ,p_effective_end_date     =>  p_effective_end_date
				  ,p_locality_pay_area_id   =>  p_locality_pay_area_id
				  ,p_leo_pay_area_code      =>  p_leo_pay_area_code
				  ,p_name                   =>  p_name
				  ,p_duty_station_code      =>  p_duty_station_code
				  ,p_is_duty_station        =>  p_is_duty_station
				  ,p_effective_date         =>  p_effective_date
				  ,p_datetrack_update_mode  =>  p_datetrack_update_mode
				  ,p_object_version_number  =>  p_object_version_number
				);

      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_duty_stations',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  --
  -- Store the original ovn in case we rollback when p_validate is true
  --
--  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);
		ghr_dut_upd.upd (
				 p_duty_station_id	    =>  p_duty_station_id
				  ,p_effective_start_date   =>  l_effective_start_date
				  ,p_effective_end_date     =>  l_effective_end_date
				  ,p_locality_pay_area_id   =>  p_locality_pay_area_id
				  ,p_leo_pay_area_code      =>  p_leo_pay_area_code
				  ,p_name                   =>  p_name
				  ,p_duty_station_code      =>  p_duty_station_code
				  ,p_msa_code               =>  p_msa_code
				  ,p_cmsa_code              =>  p_cmsa_code
				  ,p_state_or_country_code  =>  p_state_or_country_code
				  ,p_county_code            =>  p_county_code
				  ,p_is_duty_station	    =>  p_is_duty_station
				  , p_object_version_number =>  p_object_version_number
				  ,p_effective_date	    =>  p_effective_date
				  ,p_datetrack_update_mode  =>  p_datetrack_update_mode
				  );


--
  --
  -- Call After Process User Hook
  --
  begin
    ghr_duty_station_bk2.update_duty_station_a(
				   p_duty_station_id	    =>  p_duty_station_id
				  ,p_effective_start_date   =>  l_effective_start_date
				  ,p_effective_end_date     =>  l_effective_end_date
				  ,p_locality_pay_area_id   =>  p_locality_pay_area_id
				  ,p_leo_pay_area_code      =>  p_leo_pay_area_code
				  ,p_name                   =>  p_name
  				  ,p_duty_station_code      =>  p_duty_station_code
				  ,p_is_duty_station        =>  p_is_duty_station
   			          ,p_effective_date         =>  p_effective_date
				  ,p_datetrack_update_mode  =>  p_datetrack_update_mode
				  ,p_object_version_number  =>  l_object_version_number
				  );

 exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_duty_stations',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
    p_effective_start_date   := l_effective_start_date;
    p_effective_end_date     := l_effective_end_date;
    p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_duty_stations;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    When Others then
      ROLLBACK TO update_duty_stations;
      raise;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
end update_duty_station;

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_duty_station >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_duty_station
  (p_validate                      in     boolean  default false
  ,p_duty_station_id               in     number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number         in     number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_duty_station';
  l_exists                boolean      := false;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
    savepoint delete_duty_station;
  --
  --
  -- Call Before Process User Hook
  --
  IF p_validate then
   hr_utility.set_location('1.p_validate is true',10);
   else
   hr_utility.set_location('1.p_validate is false',20);
   End If;

  begin
  	ghr_duty_station_bk3.delete_duty_station_b	(
              p_duty_station_id            => p_duty_station_id
             ,p_object_version_number   => p_object_version_number
		);
    IF p_validate then
       hr_utility.set_location('2.p_validate is true',10);
    else
       hr_utility.set_location('2.p_validate is false',20);
    End If;
   exception
     when hr_api.cannot_find_prog_unit then
 	  hr_api.cannot_find_prog_unit_error
		(p_module_name	=> 'delete_ghr_duty_station'
 	        ,p_hook_type	=> 'BP'
		);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);

  --
  -- Process Logic - Delete duty_station details if the specific duty_station_id is not required
  -- for the first_noa_id specified for the pa_request_id
  -- and for the second_noa_id
IF p_validate then
   hr_utility.set_location('3.p_validate is true',10);
   else
   hr_utility.set_location('3.p_validate is false',20);
 End If;

   ghr_dut_del.del
    (p_duty_station_id	    =>  p_duty_station_id
    ,p_effective_start_date   =>  l_effective_start_date
    ,p_effective_end_date     =>  l_effective_end_date
    , p_object_version_number =>  p_object_version_number
    ,p_effective_date	    =>  p_effective_date
    ,p_datetrack_mode	    =>  p_datetrack_mode
     );

IF p_validate then
   hr_utility.set_location('4.p_validate is true',10);
   else
   hr_utility.set_location('4.p_validate is false',20);
 End If;

  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  --
  begin
  IF p_validate then
   hr_utility.set_location('5.p_validate is true',10);
   else
   hr_utility.set_location('5.p_validate is false',20);
 End If;
	ghr_duty_station_bk3.delete_duty_station_a	(
              p_duty_station_id            => p_duty_station_id
             ,p_object_version_number      => p_object_version_number
		);
IF p_validate then
   hr_utility.set_location('6.p_validate is true',10);
   else
   hr_utility.set_location('6.p_validate is false',20);
 End If;
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_ghr_duty_station'
 			        ,p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    hr_utility.set_location('inside validate',10);
    raise hr_api.validate_enabled;
  end if;
  P_effective_start_date := l_effective_start_date;
  p_effective_end_date   := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
     hr_utility.set_location('inside validate exception',20);
    ROLLBACK TO delete_duty_station;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date   := l_effective_end_date;
   hr_utility.set_location(' Leaving:'||l_proc, 25);
    --
  When Others then
    ROLLBACK TO delete_duty_station;
    raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_duty_station;
--
--
end ghr_duty_station_api;

/
