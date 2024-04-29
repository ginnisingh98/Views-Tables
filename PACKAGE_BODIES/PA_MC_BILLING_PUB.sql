--------------------------------------------------------
--  DDL for Package Body PA_MC_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_BILLING_PUB" AS
/* $Header: PAMCPUBB.pls 120.3 2005/08/07 21:31:35 lveerubh noship $ */


   PROCEDURE get_budget_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL ,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             p_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER,
             p_rsob_id                  IN    NUMBER,
             p_billing_extension_id     IN    NUMBER,
             p_billing_extension_name   IN    VARCHAR2 DEFAULT NULL,
             p_cost_budget_type_code    IN    VARCHAR2 DEFAULT NULL,
             p_rev_budget_type_code     IN    VARCHAR2 DEFAULT NULL,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_cost_amount              OUT   NOCOPY NUMBER,
             x_cost_budget_type_code    OUT   NOCOPY VARCHAR2,
             x_rev_budget_type_code     OUT   NOCOPY VARCHAR2,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER)

IS


l_project_id             NUMBER;
l_task_id                NUMBER;
l_billing_extension_id   NUMBER;

x_return_status          VARCHAR2(30);
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(240);

l_revenue_amount 	NUMBER;
l_cost_amount		NUMBER;
l_cost_budget_type_code VARCHAR2(2000);
l_rev_budget_type_code  VARCHAR2(2000);
l_error_message		VARCHAR2(2000);
l_status		NUMBER;

BEGIN

   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_error_message    := null;
     l_status     := 0;



     l_project_id   := p_project_id;


     IF (l_project_id IS NULL) AND (p_project_number IS NOT NULL) THEN


          SELECT project_id
            INTO l_project_id
            FROM pa_projects_all
           WHERE segment1 = p_project_number;


     END IF;


     l_task_id   :=  p_task_id;


     IF (l_task_id  IS NULL) AND (p_task_number IS NOT NULL) THEN

        SELECT task_id
          INTO l_task_id
          FROM  pa_tasks
         WHERE  task_number = p_task_number
	 AND    Project_ID  = l_project_id; -- Added for Bug 2675566

     END IF;



     l_billing_extension_id  := p_billing_extension_id;


     IF (l_billing_extension_id IS NULL) AND (p_billing_extension_name IS NOT NULL)  THEN

        SELECT billing_extension_id
          INTO l_billing_extension_id
          FROM pa_billing_extensions
         WHERE name = p_billing_extension_name ;

     END IF;


    /* dbms_output.put_line('Before calling the get_budget_amount API ......... '); */


    pa_mc_billing_pvt.get_budget_amount(
                      l_project_id ,
                      l_task_id ,
                      p_psob_id ,
                      p_rsob_id ,
                      l_billing_extension_id,
                      p_cost_budget_type_code,
                      p_rev_budget_type_code,
                      l_revenue_amount ,
                      l_cost_amount ,
                      l_cost_budget_type_code ,
                      l_rev_budget_type_code ,
                      x_return_status ,
                      x_msg_count ,
                      x_msg_data );


    IF (x_return_status <> 'S') THEN


      IF substr(x_msg_data, 1,3) = 'ORA' THEN

         l_error_message  := x_msg_data;

      ELSE

          l_error_message := pa_billing_values.get_message(x_msg_data);

      END IF;


       l_status  := x_msg_count ;

    END IF;

x_status := l_status ;
x_error_message := l_error_message;
x_revenue_amount	:= l_revenue_amount;
x_cost_amount		:= l_cost_amount;
x_cost_budget_type_code := l_cost_budget_type_code;
x_rev_budget_type_code  := l_rev_budget_type_code;

   EXCEPTION
     WHEN OTHERS THEN
          x_error_message 	:=  SUBSTR(SQLERRM, 1, 240);
          x_status 		:= sqlcode;
	  x_revenue_amount 	:= NULL;
	  x_cost_amount 	:= NULL;
	 x_cost_budget_type_code := NULL;
	 x_rev_budget_type_code  := NULL;
END get_budget_amount;



PROCEDURE get_cost_amount(
             p_project_id               IN    NUMBER ,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER ,
             p_accrue_through_date      IN    DATE     DEFAULT NULL,
             x_cost_amount              OUT  NOCOPY  NUMBER ,
             x_error_message            OUT  NOCOPY  VARCHAR2,
             x_status                   OUT  NOCOPY  NUMBER)
IS

l_project_id        NUMBER;
l_task_id           NUMBER;

x_return_status          VARCHAR2(30);
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(240);

--NOCOPY Changes
l_cost_amount		NUMBER;
l_status		NUMBER;
l_error_message		VARCHAR2(2000);

BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */
     l_error_message    := null;
     l_status     := 0;



     l_project_id   := p_project_id;


     IF (l_project_id IS NULL) AND (p_project_number IS NOT NULL) THEN

        SELECT project_id
          INTO l_project_id
          FROM pa_projects_all
         WHERE segment1 = p_project_number;

     END IF;


     l_task_id   :=  p_task_id;


     IF (l_task_id  IS NULL) AND (p_task_number IS NOT NULL) THEN

        SELECT task_id
          INTO l_task_id
          FROM  pa_tasks
         WHERE  task_number = p_task_number
	 AND    Project_ID  = l_project_id; -- Added for Bug 2675566

     END IF;


   pa_mc_billing_pvt.get_cost_amount(
                     l_project_id ,
                     l_task_id ,
                     p_psob_id ,
                     p_rsob_id ,
                     p_accrue_through_date ,
                     l_cost_amount ,
                     x_return_status ,
                     x_msg_count ,
                     x_msg_data );


   IF (x_return_status <> 'S') THEN

      IF substr(x_msg_data, 1,3) = 'ORA' THEN

         l_error_message  := x_msg_data;

      ELSE

          l_error_message := pa_billing_values.get_message(x_msg_data);

      END IF;

       l_status  := x_msg_count ;

   END IF;

--NOCOPY Changes
x_status := l_status;
x_error_message := l_error_message;
x_cost_amount   := l_cost_amount;

   EXCEPTION
     WHEN OTHERS THEN
          x_error_message :=  SUBSTR(SQLERRM, 1, 240);
          x_status := sqlcode;
	  x_cost_amount := NULL;
END get_cost_amount;




PROCEDURE get_pot_event_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             p_accrue_through_date      IN    DATE     DEFAULT NULL,
             x_event_amount             OUT  NOCOPY  NUMBER,
             x_error_message            OUT  NOCOPY  VARCHAR2,
             x_status                   OUT  NOCOPY  NUMBER)
IS

l_project_id        NUMBER;
l_task_id           NUMBER;


x_return_status          VARCHAR2(30);
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(240);

l_event_amount		NUMBER;
l_error_message		VARCHAR2(2000);
l_status		NUMBER;
BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_error_message    := null;
     l_status     := 0;


     l_project_id   := p_project_id;


     IF (l_project_id IS NULL) AND (p_project_number IS NOT NULL) THEN

        SELECT project_id
          INTO l_project_id
          FROM pa_projects_all
         WHERE segment1 = p_project_number;

     END IF;



     l_task_id   :=  p_task_id;


     IF (l_task_id  IS NULL) AND (p_task_number IS NOT NULL) THEN

        SELECT task_id
          INTO l_task_id
          FROM  pa_tasks
         WHERE  task_number = p_task_number
	 AND    Project_ID  = l_project_id; -- Added for Bug 2675566

     END IF;



   pa_mc_billing_pvt.get_pot_event_amount(
                     l_project_id ,
                     l_task_id ,
                     p_psob_id ,
                     p_rsob_id ,
                     p_event_id,
                     p_accrue_through_date ,
                     l_event_amount ,
                     x_return_status ,
                     x_msg_count ,
                     x_msg_data );


   IF (x_return_status <> 'S') THEN

      IF substr(x_msg_data, 1,3) = 'ORA' THEN

         l_error_message  := x_msg_data;

      ELSE

          l_error_message := pa_billing_values.get_message(x_msg_data);

      END IF;

       l_status  := x_msg_count ;

   END IF;

x_status := l_status;
x_error_message := l_error_message;
x_event_amount := l_event_amount;

   EXCEPTION
     WHEN OTHERS THEN
          x_error_message :=  SUBSTR(SQLERRM, 1, 240);
          x_status := sqlcode;
	  x_event_amount := NULL;
END get_pot_event_amount;




PROCEDURE get_Lowest_amount_left(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_funding_amount           OUT  NOCOPY  NUMBER,
             x_error_message            OUT  NOCOPY  VARCHAR2,
             x_status                   OUT  NOCOPY  NUMBER)
IS

l_project_id        NUMBER;
l_task_id           NUMBER;


x_return_status          VARCHAR2(30);
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(240);

l_funding_amount	NUMBER;
l_error_message		VARCHAR2(2000);
l_status		NUMBER;


BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_error_message    := null;
     l_status     := 0;


     l_project_id   := p_project_id;


     IF (l_project_id IS NULL) AND (p_project_number IS NOT NULL) THEN

        SELECT project_id
          INTO l_project_id
          FROM pa_projects_all
         WHERE segment1 = p_project_number;

     END IF;



     l_task_id   :=  p_task_id;

     IF (l_task_id  IS NULL) AND (p_task_number IS NOT NULL) THEN

        SELECT task_id
          INTO l_task_id
          FROM  pa_tasks
         WHERE  task_number = p_task_number
	 AND    Project_ID  = l_project_id; -- Added for Bug 2675566

     END IF;




   pa_mc_billing_pvt.get_Lowest_amount_left(
                     l_project_id ,
                     l_task_id ,
                     p_psob_id ,
                     p_rsob_id ,
                     p_event_id,
                     l_funding_amount ,
                     x_return_status ,
                     x_msg_count ,
                     x_msg_data );


   IF (x_return_status <> 'S') THEN


      IF substr(x_msg_data, 1,3) = 'ORA' THEN

         l_error_message  := x_msg_data;

      ELSE

          l_error_message := pa_billing_values.get_message(x_msg_data);

      END IF;

       l_status  := x_msg_count ;

   END IF;

x_status 	 := l_status;
x_error_message  := l_error_message;
x_funding_amount := l_funding_amount;

   EXCEPTION
     WHEN OTHERS THEN
          x_error_message :=  SUBSTR(SQLERRM, 1, 240);
          x_status := sqlcode;
	x_funding_amount := NULL;
END get_Lowest_amount_left;




PROCEDURE get_revenue_amount(
             p_project_id               IN    NUMBER,
             p_project_number           IN    VARCHAR2 DEFAULT NULL,
             p_task_id                  IN    NUMBER   DEFAULT NULL,
             P_task_number              IN    VARCHAR2 DEFAULT NULL,
             p_psob_id                  IN    NUMBER   DEFAULT NULL,
             p_rsob_id                  IN    NUMBER,
             p_event_id                 IN    NUMBER,
             x_revenue_amount           OUT   NOCOPY NUMBER,
             x_error_message            OUT   NOCOPY VARCHAR2,
             x_status                   OUT   NOCOPY NUMBER)
IS


l_project_id        NUMBER;
l_task_id           NUMBER;

x_return_status          VARCHAR2(30);
x_msg_count              NUMBER;
x_msg_data               VARCHAR2(240);

l_revenue_amount	NUMBER;
l_error_message		VARCHAR2(2000);
l_status		NUMBER;

BEGIN


   /* -----------------------------------------------------------
      Initialize the Output Variables
      ----------------------------------------------------------- */

     l_error_message    := null;
     l_status     := 0;


     l_project_id   := p_project_id;


     IF (l_project_id IS NULL) AND (p_project_number IS NOT NULL) THEN

        SELECT project_id
          INTO l_project_id
          FROM pa_projects_all
         WHERE segment1 = p_project_number;

     END IF;


     l_task_id   :=  p_task_id;


     IF (l_task_id  IS NULL) AND (p_task_number IS NOT NULL) THEN

        SELECT task_id
          INTO l_task_id
          FROM  pa_tasks
         WHERE  task_number = p_task_number
	 AND    Project_ID  = l_project_id; -- Added for Bug 2675566

     END IF;




   pa_mc_billing_pvt.get_revenue_amount(
                     p_project_id ,
                     l_task_id ,
                     p_psob_id ,
                     p_rsob_id ,
                     p_event_id,
                     l_revenue_amount ,
                     x_return_status ,
                     x_msg_count ,
                     x_msg_data );


     IF (x_return_status <> 'S') THEN

      IF substr(x_msg_data, 1,3) = 'ORA' THEN

         l_error_message  := x_msg_data;

      ELSE

          l_error_message := pa_billing_values.get_message(x_msg_data);

      END IF;

         l_status  := x_msg_count ;

     END IF;

x_revenue_amount	:=	l_revenue_amount;
x_status		:=	l_status;
x_error_message		:=	l_error_message;

   EXCEPTION
     WHEN OTHERS THEN
          x_error_message :=  SUBSTR(SQLERRM, 1, 240);
          x_status := sqlcode;
	  x_revenue_amount := NULL;
END get_revenue_amount;



END pa_mc_billing_pub;

/
