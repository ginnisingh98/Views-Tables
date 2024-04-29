--------------------------------------------------------
--  DDL for Package GHR_PRH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRH_BUS" AUTHID CURRENT_USER as
/* $Header: ghprhrhi.pkh 120.1.12000000.1 2007/01/18 14:09:34 appldev noship $ */

-- -- ----------------------------------------------------------------------------
-- |---------------------------< chk_non_updateable_args >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in  ghr_prh_shd.g_rec_type) ;
--
--
--

--  ---------------------------------------------------------------------------
--  |-----------------------< chk_pa_request_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--  Validates that the pa_request_id exists in the ghr_pa_requests_table
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_pa_request_id
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--

    Procedure chk_pa_request_id
    (p_pa_request_id         in ghr_pa_routing_history.pa_request_id%TYPE
    ,p_pa_routing_history_id in ghr_pa_routing_history.pa_routing_history_id%TYPE
    ,p_object_Version_number in ghr_pa_routing_history.object_version_number%TYPE
    );


--
-- -- ----------------------------------------------------------------------------
-- |---------------------------< chk_groupbox_id>----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the group_box_name exists in the table ghr_GROUPBOXES
--    for a specific routing_group
--
--  Pre-conditions:
--
--
--  In Arguments:
--    p_pa_routing_history_id
--    p_pa_request_id
--    p_groupbox_id
--    p_object_version_number
--
--  Post Success:
--    If the  group_box_name is valid
--    processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_groupbox_id
(p_pa_routing_history_id       in   ghr_pa_routing_history.pa_routing_history_id%TYPE
,p_pa_request_id               in   ghr_pa_requests.pa_request_id%TYPE
,p_groupbox_id                 in   ghr_pa_routing_history.groupbox_id%TYPE
,p_object_version_number       in   ghr_pa_routing_history.object_version_number%TYPE
);


-- ----------------------------------------------------------------------------
-- |---------------------------< chk_user_name>----------------------------|
-- ----------------------------------------------------------------------------

--  Description:
--    Validates that the user_name exists in the table fnd_user and
--  Pre-conditions:
--
--
--  In Arguments:
--    p_pa_routing_history_id
--    p_user_name
--    p_object_version_number
--
--  Post Success:
--    If the user_person_id is valid
--    processing continues
--
--  Post Failure:
--   An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--

 Procedure chk_user_name
 (p_pa_routing_history_id    in ghr_pa_routing_history.pa_routing_history_id%TYPE
 ,p_user_name                in ghr_pa_routing_history.user_name%TYPE
 ,p_groupbox_id              in ghr_pa_routing_history.groupbox_id%TYPE
 ,P_object_version_number    in ghr_pa_routing_history.object_version_number%TYPE
 );
--

--  ---------------------------------------------------------------------------
--  |-----------------------< chk_routing_list_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the routing_list_id exists in the table
--    ghr_routing_lists
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_routing_list_id
--    p_pa_routing_history_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--

    Procedure chk_routing_list_id
    (p_routing_list_id         in ghr_pa_routing_history.routing_list_id%TYPE
    ,p_pa_routing_history_id in ghr_pa_routing_history.pa_routing_history_id%TYPE
    ,p_object_Version_number in ghr_pa_routing_history.object_version_number%TYPE
    );

-- -- ----------------------------------------------------------------------------
-- |---------------------------< chk_rout_user_sequ_numb>----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--     Validates that the routing_seq_number exists in the table
--     'ghr_ROUTING_LIST_NAMES for the specific routing_list
--
--  Pre-conditions:
--
--
--  In Arguments:
--
--    p_pa_routing_history_id
--    p_routing_list_id
--    p_routing_seq_number
--    p_object_version_number
--
--  Post Success:
--    If the  routing_seq_number is valid
--    processing continues
--
--  Post Failure:
--   An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
  procedure chk_rout_user_sequ_numb
  (p_pa_routing_history_id        in   ghr_pa_routing_history.pa_routing_history_id%TYPE
  ,p_routing_list_id              in   ghr_pa_routing_history.routing_list_id%TYPE
  ,p_routing_seq_number           in   ghr_pa_routing_history.routing_seq_number %TYPE
  ,p_object_version_number        in   ghr_pa_routing_history.object_version_number%TYPE
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure insert_validate
          (p_rec               in ghr_prh_shd.g_rec_type);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_prh_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_prh_shd.g_rec_type);
--
end ghr_prh_bus;

 

/
