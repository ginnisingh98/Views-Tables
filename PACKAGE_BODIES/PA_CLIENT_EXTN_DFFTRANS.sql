--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_DFFTRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_DFFTRANS" AS
/* $Header: PAPDFFCB.pls 120.1.12010000.2 2009/06/09 09:31:13 atshukla ship $ */

FUNCTION DFF_map_segments_f(
            p_attribute_number         IN NUMBER,
            p_calling_module           IN VARCHAR2,
            p_trx_ref_1                IN NUMBER,
            p_trx_ref_2                IN NUMBER,
            p_trx_type                 IN VARCHAR2,
            p_system_linkage_function  IN VARCHAR2,
            p_submodule                IN VARCHAR2,
            p_expenditure_type         IN VARCHAR2,
            p_set_of_books_id          IN NUMBER,
            p_org_id                   IN NUMBER,
            p_attribute_category       IN VARCHAR2,
            p_attribute_1              IN VARCHAR2,
            p_attribute_2              IN VARCHAR2,
            p_attribute_3              IN VARCHAR2,
            p_attribute_4              IN VARCHAR2,
            p_attribute_5              IN VARCHAR2,
            p_attribute_6              IN VARCHAR2,
            p_attribute_7              IN VARCHAR2,
            p_attribute_8              IN VARCHAR2,
            p_attribute_9              IN VARCHAR2,
            p_attribute_10             IN VARCHAR2)
      RETURN pa_expenditure_items_all.attribute1%TYPE is

BEGIN
--
-- This function is the main place where user should provide the mapping
-- logic.
--
-- Logic: Given the attirubte_number as input parameter, the function returns
-- an attribute value (taken from p_attribute_1 - p_attribute_10).  The logic
-- of which p_attribute_x to return is the logic user has to decide.  The default
-- logic is to do direct mapping where p_attribute_number = N returns p_attribute_N.

			IF (p_attribute_number > 5) THEN
				IF (p_attribute_number > 7) THEN
					IF (p_attribute_number > 9) THEN
						RETURN p_attribute_10;
					ELSIF (p_attribute_number < 9) THEN /* 7 < x < 9 */
						RETURN p_attribute_8;
					ELSE RETURN p_attribute_9;
					END IF;
				ELSE /* 5 < x <= 7 */
					IF (p_attribute_number < 7) THEN
						RETURN p_attribute_6;
					ELSE RETURN p_attribute_7;
					END IF;
				END IF;
			ELSE
				IF (p_attribute_number < 3) THEN
					IF (p_attribute_number < 2) THEN
						RETURN p_attribute_1;
					ELSE RETURN p_attribute_2;
					END IF;
				ELSE  /* 3 <= x <= 5 */
					IF (p_attribute_number  < 4) THEN
						RETURN p_attribute_3;
					ELSIF (p_attribute_number < 5) THEN
						RETURN p_attribute_4;
					ELSE RETURN p_attribute_5;
					END IF;
				END IF;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				raise;
END DFF_map_segments_f;

PROCEDURE DFF_map_segments_PA_and_AP (
            p_calling_module           IN VARCHAR2,
            p_trx_ref_1                IN NUMBER,
            p_trx_ref_2                IN NUMBER,
            p_trx_type                 IN VARCHAR2,
            p_system_linkage_function  IN VARCHAR2,
            p_submodule                IN VARCHAR2,
            p_expenditure_type         IN VARCHAR2,
            p_set_of_books_id          IN NUMBER,
            p_org_id                   IN NUMBER,
            p_attribute_category       IN OUT NOCOPY VARCHAR2,
            p_attribute_1              IN OUT NOCOPY VARCHAR2,
            p_attribute_2              IN OUT NOCOPY VARCHAR2,
            p_attribute_3              IN OUT NOCOPY VARCHAR2,
            p_attribute_4              IN OUT NOCOPY VARCHAR2,
            p_attribute_5              IN OUT NOCOPY VARCHAR2,
            p_attribute_6              IN OUT NOCOPY VARCHAR2,
            p_attribute_7              IN OUT NOCOPY VARCHAR2,
            p_attribute_8              IN OUT NOCOPY VARCHAR2,
            p_attribute_9              IN OUT NOCOPY VARCHAR2,
            p_attribute_10             IN OUT NOCOPY VARCHAR2,
            x_status_code              OUT NOCOPY VARCHAR2) IS

			counter NUMBER;
			temp_attribute_a attribute_a;
			temp_attribute_1 VARCHAR2(150);
			temp_attribute_2 VARCHAR2(150);
         temp_attribute_3 VARCHAR2(150);
         temp_attribute_4 VARCHAR2(150);
         temp_attribute_5 VARCHAR2(150);
         temp_attribute_6 VARCHAR2(150);
         temp_attribute_7 VARCHAR2(150);
         temp_attribute_8 VARCHAR2(150);
         temp_attribute_9 VARCHAR2(150);
			temp_attribute_10 VARCHAR2(150);

		BEGIN
--
--This procedure does the DFF segment mapping by calling DFF_map_segments_f
--It stores the mapped segments in the p_attribute_x parameters.
--While DFF_map_segments_f takes care of maping segments, user still need
--to do attribute_category mapping in this procedure.  Example of attirubte_category
--mapping is shown below.

			/* User should set the corresponding attribute_category for
		      expenditure items here:
				For instance AP invoice distributions DFF reference field is
				invoice type lookup code and PA expenditure items DFF reference
				field is system linkage function, then we can have the following
				mapping logic:
						Invoice Type              System Linkage Function
						EXPENSE REPORT            ER
				      STANDARD                  VI
						.....
			IF (p_attribute_category = 'EXPENSE REPORT') THEN
				p_attribute_category := 'ER';
			......

			*/


			/* store IN parameters in temporary variables */
			temp_attribute_1 := p_attribute_1;
         temp_attribute_2 := p_attribute_2;
         temp_attribute_3 := p_attribute_3;
         temp_attribute_4 := p_attribute_4;
         temp_attribute_5 := p_attribute_5;
         temp_attribute_6 := p_attribute_6;
         temp_attribute_7 := p_attribute_7;
         temp_attribute_8 := p_attribute_8;
         temp_attribute_9 := p_attribute_9;
			temp_attribute_10 := p_attribute_10;
			counter := 1;

			WHILE counter <= 10 LOOP
			/* Call the mapping function 10 times */
			temp_attribute_a(counter) := DFF_map_segments_f (
				   p_attribute_number        =>counter,
					p_calling_module          =>p_calling_module,
					p_trx_ref_1               =>p_trx_ref_1,
					p_trx_ref_2               =>p_trx_ref_2,
					p_trx_type                =>p_trx_type,
					p_system_linkage_function =>p_system_linkage_function,
					p_submodule               =>p_submodule,
					p_expenditure_type        =>p_expenditure_type,
					p_set_of_books_id         =>p_set_of_books_id,
					p_org_id                  =>p_org_id,
					p_attribute_category      =>p_attribute_category,
					p_attribute_1             =>temp_attribute_1,
               p_attribute_2             =>temp_attribute_2,
               p_attribute_3             =>temp_attribute_3,
               p_attribute_4             =>temp_attribute_4,
               p_attribute_5             =>temp_attribute_5,
               p_attribute_6             =>temp_attribute_6,
               p_attribute_7             =>temp_attribute_7,
               p_attribute_8             =>temp_attribute_8,
               p_attribute_9             =>temp_attribute_9,
               p_attribute_10            =>temp_attribute_10);

			counter := counter + 1;
			END LOOP;

			p_attribute_1 := temp_attribute_a(1);
			p_attribute_2 := temp_attribute_a(2);
         p_attribute_3 := temp_attribute_a(3);
         p_attribute_4 := temp_attribute_a(4);
         p_attribute_5 := temp_attribute_a(5);
         p_attribute_6 := temp_attribute_a(6);
         p_attribute_7 := temp_attribute_a(7);
         p_attribute_8 := temp_attribute_a(8);
         p_attribute_9 := temp_attribute_a(9);
         p_attribute_10 := temp_attribute_a(10);
			x_status_code := NULL;

		EXCEPTION
			WHEN OTHERS THEN
				raise;
END DFF_map_segments_PA_and_AP;

END PA_CLIENT_EXTN_DFFTRANS;


/
