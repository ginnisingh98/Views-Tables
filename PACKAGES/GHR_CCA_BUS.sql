--------------------------------------------------------
--  DDL for Package GHR_CCA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CCA_BUS" AUTHID CURRENT_USER as
/* $Header: ghccarhi.pkh 120.0 2005/05/29 02:50:17 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_compl_appeal_id
--     already exists.
--
--  In Arguments:
--    p_compl_appeal_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
  procedure set_security_group_id
  (p_compl_appeal_id                      in number
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_compl_appeal_id
--     already exists.
--
--  In Arguments:
--    p_compl_appeal_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_compl_appeal_id                      in     number
  ) RETURN varchar2;
--

PROCEDURE chk_appealed_to(p_compl_appeal_id         in ghr_compl_appeals.compl_appeal_id%TYPE,
			  p_appealed_to             in ghr_compl_appeals.appealed_to%TYPE,
		          p_effective_date 	    in date,
			  p_object_version_number   in number);


PROCEDURE chk_reason_for_appeal(p_compl_appeal_id         in ghr_compl_appeals.compl_appeal_id%TYPE,
			        p_reason_for_appeal       in ghr_compl_appeals.reason_for_appeal%TYPE,
		                p_effective_date 	  in date,
			        p_object_version_number   in number);

PROCEDURE chk_decision(p_compl_appeal_id        in ghr_compl_appeals.compl_appeal_id%TYPE,
		       p_appealed_to 	        in ghr_compl_appeals.appealed_to%TYPE,
		       p_decision   	        in ghr_compl_appeals.decision%TYPE,
                       p_effective_date 	in date,
		       p_object_version_number  in number);

PROCEDURE chk_rfr_requested_by(p_compl_appeal_id         in ghr_compl_appeals.compl_appeal_id%TYPE,
			       p_rfr_requested_by        in ghr_compl_appeals.rfr_requested_by%TYPE,
		               p_effective_date          in date,
			       p_object_version_number   in number);

PROCEDURE chk_rfr_decision(p_compl_appeal_id         in ghr_compl_appeals.compl_appeal_id%TYPE,
			   p_rfr_decision 	     in ghr_compl_appeals.rfr_decision%TYPE,
		           p_effective_date 	     in date,
			   p_object_version_number   in number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ghr_cca_shd.g_rec_type
  );
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
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ghr_cca_shd.g_rec_type
  );
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
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in ghr_cca_shd.g_rec_type
  );
--
end ghr_cca_bus;

 

/
