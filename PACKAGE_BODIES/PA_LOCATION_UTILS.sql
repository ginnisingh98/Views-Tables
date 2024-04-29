--------------------------------------------------------
--  DDL for Package Body PA_LOCATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LOCATION_UTILS" AS
-- $Header: PALOUTLB.pls 120.2 2005/11/03 12:04:49 ramurthy noship $
--  PROCEDURE
--              Check_Country_Name_Or_Code
--  PURPOSE
--              This procedure does the following
--              If country name is passed converts it to the code
--		If code is passed, based on the check_id_flag validates it
--  HISTORY
--  23-JUN-2000      R. Krishnamurthy       Created
--  13-APR-2001   Ranga Iyengar        Modified Check_Country_Name_Or_Code api to validate
--                                    LOV fileds bug fix : 1364336
--  04-APR-2002   adabdull            Return success status for Check_Location_Exists
--                                    when no_data_found (bug2304360)
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
				( p_country_code  IN VARCHAR2
				 ,p_country_name  IN VARCHAR2
				 ,p_check_id_flag IN VARCHAR2 default 'A'
				 ,x_country_code OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				 ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


        l_current_id    VARCHAR2(100);
        l_id_found_flag  VARCHAR2(1):= 'N';
        l_num_ids       NUMBER := 0;
        CURSOR c_ids IS
                SELECT territory_code
                FROM   fnd_territories_vl
                WHERE  territory_short_name = p_country_name;



BEGIN
        IF ((p_country_code IS NOT NULL) AND
            (p_country_code <> FND_API.G_MISS_CHAR)) THEN
                IF p_check_id_flag = 'Y' THEN
                        SELECT territory_code
                        INTO   x_country_code
                        FROM   fnd_territories
                        WHERE  territory_code = p_country_code;
                ---------------------------------------------------
                -- Added the following code to fix the bug : 1364336
                -- to validate the LOV based on the user inputs
                ---------------------------------------------------
                ELSIF (p_check_id_flag = 'N') THEN
                        -- No ID validation necessary
                        x_country_code := p_country_code;

                ELSIF (p_check_id_flag = 'A') THEN

                        IF (p_country_name IS NULL) THEN
                                -- Return a null ID since the name is null.
                                x_country_code := NULL;

                        ELSE
                                -- Find the ID which matches the Name passed
                                OPEN c_ids;
                                LOOP
                                        FETCH c_ids INTO l_current_id;
                                        EXIT WHEN c_ids%NOTFOUND;
                                        IF (l_current_id = p_country_code) THEN
                                                l_id_found_flag := 'Y';
                                                x_country_code := p_country_code;
                                        END IF;
                                END LOOP;
                                l_num_ids := c_ids%ROWCOUNT;
                                CLOSE c_ids;

                                IF (l_num_ids = 0) THEN
                                        -- No IDs for name
                                        RAISE NO_DATA_FOUND;
                                ELSIF (l_num_ids = 1) THEN
                                        -- Since there is only one ID for the name use it.
                                        x_country_code := l_current_id;
                                ELSIF (l_num_ids > 0 OR l_id_found_flag = 'N') THEN
                                        -- More than one ID for the name and none of the IDs matched
                                        -- the ID passed in.
                                        RAISE TOO_MANY_ROWS;
                                END IF;
                        END IF;  -- end if for country name
                --x_country_code := p_country_code;
                 END IF; -- end if for check id flag
        ELSE
                If p_country_name is NOT NULL then
                        SELECT territory_code
                        INTO   x_country_code
                        FROM   fnd_territories_vl
                        WHERE  territory_short_name = p_country_name;

                Else
                        x_country_code := NULL;
                End if;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_COUNTRY_INVALID';
	  x_country_code := NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_COUNTRY_AMBIGOUS';
	  x_country_code := NULL;
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 x_country_code := NULL;
         RAISE ;

END Check_Country_Name_Or_Code;

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
procedure Get_ORG_Location_Details
			( p_organization_id     IN NUMBER
			 ,x_country_name       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                         ,x_city               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_region             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_country_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN

   /* Bug 4092701 - Commented the prm_licensed check   */
  /*    IF PA_INSTALL.IS_PRM_LICENSED = 'Y' THEN  */

           SELECT l.country,
                  t.territory_short_name,
                  l.town_or_city,
                  decode(l.region_2, NULL, l.region_1, l.region_2)
           INTO   x_country_code,
                  x_country_name,
                  x_city,
                  x_region
           FROM   hr_all_organization_units o, -- Bug 4684196
                  -- hr_organization_units o,
                  hr_locations_all l,
                  fnd_territories_vl t
           WHERE  t.territory_code = l.country
             AND  o.location_id = l.location_id
             AND  o.organization_id = p_organization_id ;

        IF x_country_code IS NULL THEN

             RAISE NO_DATA_FOUND ;
        ELSE

             x_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF ;

   /* ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    END IF ; */


EXCEPTION
        WHEN NO_DATA_FOUND THEN
/* Commented the below two lines for bug 2686227 */
      /*  x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_ORGANIZATION_INVALID';
      */
          NULL;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_ORGANIZATION_AMBIGOUS';
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;

END Get_ORG_Location_Details;

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
procedure Get_EMP_Location_Details
			( p_person_id          IN NUMBER
                         ,p_assign_date        IN  DATE
			 ,x_country_name       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                         ,x_city               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_region             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_country_code       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			 ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN

    /* Bug 4092701 - Commented the prm_licensed check   */
  /*  IF PA_INSTALL.IS_PRM_LICENSED = 'Y' THEN  */

           SELECT l.country,
                  t.territory_short_name,
                  l.town_or_city,
                  decode(l.region_2, NULL, l.region_1, l.region_2)
           INTO   x_country_code,
                  x_country_name,
                  x_city,
                  x_region
           FROM   per_addresses l,
                  fnd_territories_vl t
           WHERE  t.territory_code = l.country
             AND  l.primary_flag = 'Y'
             AND  p_assign_date  between l.DATE_FROM and nvl(l.DATE_TO, p_assign_date)
             AND  l.person_id = p_person_id ;


   /* ELSE */

        x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* END IF ; */

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL ;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_EMP_LOCATION_AMBIGOUS';
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;

END Get_EMP_Location_Details;

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
			 ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


BEGIN

     /* Bug 4092701 - Commented the prm_licensed check   */
  /*    IF PA_INSTALL.IS_PRM_LICENSED = 'Y' THEN  */

           SELECT l.country_code,
                  t.territory_short_name,
                  l.city,
                  l.region
           INTO   x_country_code,
                  x_country_name,
                  x_city,
                  x_region
           FROM   pa_locations l,
                  fnd_territories_vl t
           WHERE  t.territory_code = l.country_code
             AND  l.location_id = p_location_id ;

/*    END IF ; */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PROJ_LOCATION_INVALID';
        WHEN TOO_MANY_ROWS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PROJ_LOCATION_AMBIGOUS';
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;

END Get_PA_Location_Details;

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
                                ,x_return_status OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
BEGIN

         SELECT l.location_id
           INTO x_location_id
           FROM pa_locations l
          WHERE ( ( l.city = p_city)
                 OR (l.city IS NULL AND p_city IS NULL))
            AND ( (l.region = p_region)
                 OR (l.region IS NULL AND p_region IS NULL))
            AND l.country_code = p_country_code ;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_location_id := NULL ;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;

END Check_Location_Exists;

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
			,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

      l_location_id    NUMBER;
      l_return_status  VARCHAR2(30);
      l_created_by     NUMBER := fnd_global.user_id ;
      l_login_id       NUMBER := fnd_global.login_id ;
      l_ROW_ID         ROWID ;

BEGIN

   /* Bug 4092701 - Commented the prm_licensed check   */
 /*   IF PA_INSTALL.IS_PRM_LICENSED = 'Y' THEN  */

        IF p_country_code is NULL THEN

           x_error_message_code  := 'PA_PROJ_COUNTRY_NULL' ;

        ELSE


             Check_Location_Exists (  p_country_code  => p_country_code
                                    , p_city          => p_city
                                    , p_region        => p_region
                                    , x_location_id   => l_location_id
                                    , x_return_status => l_return_status );

             IF l_location_id IS NULL THEN

                PA_LOCATIONS_PKG.INSERT_ROW (
                                    p_CITY               => p_city
                                  , p_REGION             => p_region
                                  , p_COUNTRY_CODE       => p_country_code
                                  , p_CREATION_DATE      => sysdate
                                  , p_CREATED_BY         => l_created_by
                                  , p_LAST_UPDATE_DATE   => sysdate
                                  , p_LAST_UPDATED_BY    => l_login_id
                                  , p_LAST_UPDATE_LOGIN  => l_login_id
                                  , X_ROWID              => l_ROW_ID
                                  , X_LOCATION_ID        => l_location_id );

             END IF;

             x_location_id   := l_location_id ;
             x_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;
  /*  ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    END IF ; */


EXCEPTION
        WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE ;

END Get_Location;

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
			        x_country_name      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

BEGIN
   SELECT l.country_code,
          t.territory_short_name
   INTO   x_country_code,
          x_country_name
   FROM   pa_locations l,
          fnd_territories_vl t
   WHERE  t.territory_code = l.country_code
     AND  l.location_id = p_location_id;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
           x_country_code   := '';
           x_country_name   := '';
	 WHEN OTHERS THEN
	   x_country_code   := '';
	   x_country_name   := '';
END Get_Country_Code_Name;


END pa_location_utils ;

/
