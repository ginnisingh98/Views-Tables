--------------------------------------------------------
--  DDL for Package PA_LOCATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LOCATION_UTILS" AUTHID CURRENT_USER AS
-- $Header: PALOUTLS.pls 120.1 2005/08/19 16:35:50 mwasowic noship $

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Check_Country_Name_Or_Code
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure does the the following
--                1>. If a country name is passed it derrives the country code.
--                2>. If a country code is passed, the code is validated based on
--                    the check id flag.
--
--                If a valid country is not found an invalid country error code
--                is returned.  Also is there are more that one records retrieved
--                then it will flag an error of ambigous country.
--
--
-- Parameters   :
--              p_country_code                  IN  VARCHAR2
--              p_country_name                  IN  VARCHAR2
--              p_check_id_flag                 IN  VARCHAR2
--              x_country_code                  OUT VARCHAR2
--              x_return_status                 OUT VARCHAR2
--              x_error_message_code            OUT VARCHAR2

-- Version      : Initial version       115.0
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE Check_Country_Name_Or_Code
				( p_country_code       IN  VARCHAR2
				 ,p_country_name       IN  VARCHAR2
				 ,p_check_id_flag      IN  VARCHAR2 default 'A'
				 ,x_country_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				 ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Get_ORG_Location_Details
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Procedure    : This procedure accepts the organization id and returns the following
--                1>. Country name
--                2>. City
--                3>. Region/State
--                4>. Country Code
--
--                It is used to get the location of an organization.
--
-- Parameters   :
--              p_organization_id               IN  NUMBER
--              x_country_name                  OUT VARCHAR2
--              x_city                          OUT VARCHAR2
--              x_region                        OUT VARCHAR2
--              x_country_code                  OUT VARCHAR2
--              x_return_status                 OUT VARCHAR2
--              x_error_message_code            OUT VARCHAR2

-- Version      : Initial version       115.0
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE Get_ORG_Location_Details
			( p_organization_id    IN  NUMBER
			 ,x_country_name       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                         ,x_city               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_region             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_country_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Get_EMP_Location_Details
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Procedure    : This procedure accepts the person id and returns the following
--                1>. Country name
--                2>. City
--                3>. Region/State
--                4>. Country Code
--
--                It is used to get the primary location of an person.
--
--
--
-- Parameters   :
--              p_person_id                     IN  NUMBER
--              x_country_name                  OUT VARCHAR2
--              x_city                          OUT VARCHAR2
--              x_region                        OUT VARCHAR2
--              x_country_code                  OUT VARCHAR2
--              x_return_status                 OUT VARCHAR2
--              x_error_message_code            OUT VARCHAR2

-- Version      : Initial version       115.0
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE Get_EMP_Location_Details
			( p_person_id           IN NUMBER
                         ,p_assign_date         IN DATE
			 ,x_country_name       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                         ,x_city               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_region             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_country_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Get_PA_Location_Details
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Procedure    : This procedure accepts the location id and returns the following
--                1>. Country name
--                2>. City
--                3>. Region/State
--                4>. Country Code
--
--                It is used to get the project location.
--
--
--
-- Parameters   :
--              p_location_id                   IN  NUMBER
--              x_country_name                  OUT VARCHAR2
--              x_city                          OUT VARCHAR2
--              x_region                        OUT VARCHAR2
--              x_country_code                  OUT VARCHAR2
--              x_return_status                 OUT VARCHAR2
--              x_error_message_code            OUT VARCHAR2

-- Version      : Initial version       11.0
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE Get_PA_Location_Details
			( p_location_id   IN NUMBER
			 ,x_country_name  OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                         ,x_city          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_region        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_country_code OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Check_Location_Exists
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Procedure    : This procedure is used to check if a valid project location
--                for that combination of country, city and region.
--
--
--
-- Parameters   :
--              p_country_code                  IN  VARCHAR2
--              p_city                          IN  VARCHAR2
--              p_region                        IN  VARCHAR2
--              x_location_id                   OUT NUMBER
--              x_return_status                 OUT VARCHAR2

-- Version      : Initial version       115.0
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE Check_Location_Exists( p_country_code  IN VARCHAR2
                                ,p_city          IN VARCHAR2
                                ,p_region        IN VARCHAR2
                                ,x_location_id   OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
                                ,x_return_status OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Get_Location
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Procedure    : This procedure accepts country code, city and region and input
--                parameters, checks if the location exists and returns the location
--                id if the location exists. If the location does not exist a new
--                location is created with the country, city and region and the new
--                location id is returned.
--
--
-- Parameters   :
--              p_country_code                  IN  VARCHAR2
--              p_city                          IN  VARCHAR2
--              p_region                        IN  VARCHAR2
--              x_location_id                   OUT NUMBER
--              x_return_status                 OUT VARCHAR2

-- Version      : Initial version       115.0
--
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE Get_Location ( p_country_code  IN VARCHAR2
                        ,p_city          IN VARCHAR2
                        ,p_region        IN VARCHAR2
                        ,x_location_id   OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
                        ,x_return_status OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
			,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_location_utils.Get_Country_Code_Name
--
-- Procedure    : This procedure returns country code and count name
--                from location id.
--
-- Parameters   :
--              p_location                      IN  NUMBER
--              x_country_code                  IN  VARCHAR2
--              x_country_name                  IN  VARCHAR2
--
-- End of comments
-------------------------------------------------------------------------------
Procedure Get_Country_Code_Name(p_location_id       IN NUMBER,
			        x_country_code      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			        x_country_name      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_location_utils ;
 

/
