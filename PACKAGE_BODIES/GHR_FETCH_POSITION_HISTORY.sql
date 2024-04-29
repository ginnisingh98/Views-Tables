--------------------------------------------------------
--  DDL for Package Body GHR_FETCH_POSITION_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_FETCH_POSITION_HISTORY" AS
/* $Header: ghfetdpo.pkb 120.0.12010000.2 2009/05/26 10:41:05 utokachi noship $ */
g_package_name varchar2(31) := 'GHR_FETCH_POSITION_HISTORY.';
-- -------------------------------
   PROCEDURE get_position_detail (
-- -------------------------------
     p_position_id                IN     per_positions.position_id%type,
     p_session_date               IN     DATE,
     p_date_effective             IN out NOCOPY per_positions.date_effective%type,
     p_date_end                   IN out NOCOPY per_positions.date_end%type,
     p_working_hours              IN out NOCOPY per_positions.working_hours%type,
     p_time_normal_start          IN out NOCOPY per_positions.time_normal_start%type,
     p_time_normal_finish         IN out NOCOPY per_positions.time_normal_finish%type,
     p_probation_period           IN out NOCOPY per_positions.probation_period%type,
     p_probation_period_units     IN out NOCOPY per_positions.probation_period_units%type,
     p_position_definition_id     IN out NOCOPY per_positions.position_definition_id%type,
     p_business_group_id          IN out NOCOPY per_positions.business_group_id%type,
     p_job_id                     IN out NOCOPY per_positions.job_id%type,
     p_organization_id            IN out NOCOPY per_positions.organization_id%type,
     p_successor_position_id      IN out NOCOPY per_positions.successor_position_id%type,
     p_relief_position_id         IN out NOCOPY per_positions.relief_position_id%type,
     p_location_id                IN out NOCOPY per_positions.location_id%type,
     p_comments                   IN out NOCOPY per_positions.comments%type,
     p_status                     IN out NOCOPY per_positions.status%type,
     p_frequency                  IN out NOCOPY per_positions.frequency%type,
     p_name                       IN out NOCOPY per_positions.name%type,
     p_replacement_required_flag  IN out NOCOPY per_positions.replacement_required_flag%type,
     p_request_id                 IN out NOCOPY per_positions.request_id%type,
     p_program_application_id     IN out NOCOPY per_positions.program_application_id%type,
     p_program_id                 IN out NOCOPY per_positions.program_id%type,
     p_program_update_date        IN out NOCOPY per_positions.program_update_date%type,
     p_attribute_category         IN out NOCOPY per_positions.attribute_category%type,
     p_attribute1                 IN out NOCOPY per_positions.attribute1%type,
     p_attribute2                 IN out NOCOPY per_positions.attribute2%type,
     p_attribute3                 IN out NOCOPY per_positions.attribute3%type,
     p_attribute4                 IN out NOCOPY per_positions.attribute4%type,
     p_attribute5                 IN out NOCOPY per_positions.attribute5%type,
     p_attribute6                 IN out NOCOPY per_positions.attribute6%type,
     p_attribute7                 IN out NOCOPY per_positions.attribute7%type,
     p_attribute8                 IN out NOCOPY per_positions.attribute8%type,
     p_attribute9                 IN out NOCOPY per_positions.attribute9%type,
     p_attribute10                IN out NOCOPY per_positions.attribute10%type,
     p_attribute11                IN out NOCOPY per_positions.attribute11%type,
     p_attribute12                IN out NOCOPY per_positions.attribute12%type,
     p_attribute13                IN out NOCOPY per_positions.attribute13%type,
     p_attribute14                IN out NOCOPY per_positions.attribute14%type,
     p_attribute15                IN out NOCOPY per_positions.attribute15%type,
     p_attribute16                IN out NOCOPY per_positions.attribute16%type,
     p_attribute17                IN out NOCOPY per_positions.attribute17%type,
     p_attribute18                IN out NOCOPY per_positions.attribute18%type,
     p_attribute19                IN out NOCOPY per_positions.attribute19%type,
     p_attribute20                IN out NOCOPY per_positions.attribute20%type,
     p_last_update_date           IN out NOCOPY per_positions.last_update_date%type,
     p_last_updated_by            IN out NOCOPY per_positions.last_updated_by%type,
     p_last_update_login          IN out NOCOPY per_positions.last_update_login%type,
     p_created_by                 IN out NOCOPY per_positions.created_by%type,
     p_creation_date              IN out NOCOPY per_positions.creation_date%type,
     p_org_name                   IN out NOCOPY hr_all_organization_units.name%type,
     p_job_name                   IN out NOCOPY per_jobs.name%type,
     p_location_code              IN out NOCOPY hr_locations.location_code%type,
     p_status_desc                IN out NOCOPY hr_lookups.meaning%type,
     p_frequency_desc             IN out NOCOPY hr_lookups.meaning%type,
     p_prob_units_desc            IN out NOCOPY hr_lookups.meaning%type,
     p_rep_req_desc               IN out NOCOPY hr_lookups.meaning%type,
     p_rel_name                   IN out NOCOPY per_positions.name%type,
     p_succ_name                  IN out NOCOPY per_positions.name%type,
     p_result_code                IN out NOCOPY varchar2
  )
  IS
   l_proc   VARCHAR2(61)  := g_package_name || 'CLOSE_CURSOR';
   l_position_rec       per_positions%rowtype;
   l_position_rec_temp  per_positions%rowtype;
   l_result_code        varchar2(30);

   CURSOR c_org_name (p_org_id IN NUMBER) IS
     SELECT org.name
     FROM hr_all_organization_units org
     WHERE org.organization_id = p_org_id;

   CURSOR c_job_name (p_job_id IN NUMBER) IS
     SELECT job.name
     FROM per_jobs job
     WHERE job.job_id = p_job_id;

   CURSOR c_loc_code (p_loc_id IN NUMBER) IS
     SELECT loc.location_code
     FROM hr_locations loc
     WHERE loc.location_id = p_loc_id;

   CURSOR c_lookup_meaning (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
     SELECT hrl.meaning
     FROM hr_lookups hrl
     WHERE hrl.lookup_code         =  p_lookup_code
       AND hrl.lookup_type         =  p_lookup_type;

   BEGIN
       hr_utility.set_location('Entering  '|| l_proc, 10);
       /*GHR_HISTORY_FETCH.fetch_position (
           p_position_id                   => p_position_id,
           p_date_effective                => p_session_date,
           p_position_data                 => l_position_rec,
           p_result_code                   => p_result_code );
        */

       p_date_effective             := l_position_rec.date_effective;
       p_date_end                   := l_position_rec.date_end;
       p_working_hours              := l_position_rec.working_hours;
       p_time_normal_start          := l_position_rec.time_normal_start;
       p_time_normal_finish         := l_position_rec.time_normal_finish;
       p_probation_period           := l_position_rec.probation_period;
       p_probation_period_units     := l_position_rec.probation_period_units;
       p_position_definition_id     := l_position_rec.position_definition_id;
       p_business_group_id          := l_position_rec.business_group_id;
       p_job_id                     := l_position_rec.job_id;
       p_organization_id            := l_position_rec.organization_id;
       p_successor_position_id      := l_position_rec.successor_position_id;
       p_relief_position_id         := l_position_rec.relief_position_id;
       p_location_id                := l_position_rec.location_id;
       p_comments                   := l_position_rec.comments;
       p_status                     := l_position_rec.status;
       p_frequency                  := l_position_rec.frequency;
       p_name                       := l_position_rec.name;
       p_replacement_required_flag  := l_position_rec.replacement_required_flag;
       p_request_id                 := l_position_rec.request_id;
       p_program_application_id     := l_position_rec.program_application_id;
       p_program_id                 := l_position_rec.program_id;
       p_program_update_date        := l_position_rec.program_update_date;
       p_attribute_category         := l_position_rec.attribute_category;
       p_attribute1                 := l_position_rec.attribute1;
       p_attribute2                 := l_position_rec.attribute2;
       p_attribute3                 := l_position_rec.attribute3;
       p_attribute4                 := l_position_rec.attribute4;
       p_attribute5                 := l_position_rec.attribute5;
       p_attribute6                 := l_position_rec.attribute6;
       p_attribute7                 := l_position_rec.attribute7;
       p_attribute8                 := l_position_rec.attribute8;
       p_attribute9                 := l_position_rec.attribute9;
       p_attribute10                := l_position_rec.attribute10;
       p_attribute11                := l_position_rec.attribute11;
       p_attribute12                := l_position_rec.attribute12;
       p_attribute13                := l_position_rec.attribute13;
       p_attribute14                := l_position_rec.attribute14;
       p_attribute15                := l_position_rec.attribute15;
       p_attribute16                := l_position_rec.attribute16;
       p_attribute17                := l_position_rec.attribute17;
       p_attribute18                := l_position_rec.attribute18;
       p_attribute19                := l_position_rec.attribute19;
       p_attribute20                := l_position_rec.attribute20;
       p_last_update_date           := l_position_rec.last_update_date;
       p_last_updated_by            := l_position_rec.last_updated_by;
       p_last_update_login          := l_position_rec.last_update_login;
       p_created_by                 := l_position_rec.created_by;
       p_creation_date              := l_position_rec.creation_date;

       /*GHR_HISTORY_FETCH.fetch_position (
           p_position_id                   => l_position_rec.relief_position_id,
           p_date_effective                => p_session_date,
           p_position_data                 => l_position_rec_temp,
           p_result_code                   => l_result_code );
*/
       p_rel_name                   := l_position_rec_temp.name;
 /*      GHR_HISTORY_FETCH.fetch_position (
           p_position_id                   => l_position_rec.successor_position_id,
           p_date_effective                => p_session_date,
           p_position_data                 => l_position_rec_temp,
           p_result_code                   => l_result_code );
*/
       p_succ_name                  := l_position_rec_temp.name;
       OPEN c_org_name (l_position_rec.organization_id);
       FETCH c_org_name INTO p_org_name;
       CLOSE c_org_name;

       OPEN c_job_name (l_position_rec.job_id);
       FETCH c_job_name INTO p_job_name;
       CLOSE c_job_name;

       OPEN c_loc_code (l_position_rec.location_id);
       FETCH c_loc_code INTO p_location_code;
       CLOSE c_loc_code;

       OPEN c_lookup_meaning ('FREQUENCY', l_position_rec.frequency);
       FETCH c_lookup_meaning INTO p_frequency_desc;
       CLOSE c_lookup_meaning;

       OPEN c_lookup_meaning ('YES_NO', l_position_rec.replacement_required_flag);
       FETCH c_lookup_meaning INTO p_rep_req_desc;
       CLOSE c_lookup_meaning;

       OPEN c_lookup_meaning ('QUALIFYING_UNITS', l_position_rec.probation_period_units);
       FETCH c_lookup_meaning INTO p_prob_units_desc;
       CLOSE c_lookup_meaning;

       OPEN c_lookup_meaning ('POSITION_STATUS', l_position_rec.status);
       FETCH c_lookup_meaning INTO p_status_desc;
       CLOSE c_lookup_meaning;

       hr_utility.set_location('Exiting  '|| l_proc, 100);
     END;
END GHR_FETCH_POSITION_HISTORY;

/
