--------------------------------------------------------
--  DDL for Package PA_INTERFACE_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INTERFACE_UTILS_PUB" AUTHID DEFINER as
--$Header: PAPMUTPS.pls 120.2 2005/08/16 23:33:13 avaithia noship $

G_PA_MISS_NUM   CONSTANT   NUMBER := 1.7E20;
G_PA_MISS_DATE  CONSTANT   DATE   := TO_DATE('01/01/4712','DD/MM/YYYY');
G_PA_MISS_CHAR  CONSTANT   VARCHAR2(3) := '^';

--bug 2471668
--Advanced Project Security in AMG Changes
G_PROJECT_ID                 NUMBER;
G_ADVANCED_PROJ_SEC_FLAG     VARCHAR2(1) := 'N'; /* Bug#2810699-Defaulted the value to N */
--bug 2471668


PROCEDURE get_messages
(p_encoded        IN VARCHAR2 := FND_API.G_FALSE,
 p_msg_index      IN NUMBER   := FND_API.G_MISS_NUM,
 p_msg_count      IN NUMBER   := 1,
 p_msg_data       IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_data           OUT NOCOPY VARCHAR2,  /*Added the nocopy check for 4537865 */
 p_msg_index_out  OUT NOCOPY NUMBER            ) ;  /*Added the nocopy check for 4537865 */

FUNCTION get_bg_id RETURN NUMBER;
pragma RESTRICT_REFERENCES (get_bg_id, WNDS, WNPS);

/** Bug 1940353 - Added a parameter p_resp_appl_id in this procedure **/

PROCEDURE Set_Global_Info
         (p_api_version_number  IN NUMBER,
          p_responsibility_id   IN NUMBER := G_PA_MISS_NUM,
          p_user_id         IN NUMBER := G_PA_MISS_NUM,
          p_resp_appl_id        IN NUMBER := 275,
          p_advanced_proj_sec_flag IN VARCHAR2 := 'N',   --bug 2471668
          p_calling_mode        IN VARCHAR2 := 'AMG',    --bug 2783845
          p_operating_unit_id   IN NUMBER := G_PA_MISS_NUM, -- 4363092 Added for MOAC Changes
          p_msg_count          OUT NOCOPY NUMBER,  /*Added the nocopy check for 4537865 */
          p_msg_data           OUT NOCOPY VARCHAR2,  /*Added the nocopy check for 4537865 */
          p_return_status      OUT NOCOPY VARCHAR2 ) ;  /*Added the nocopy check for 4537865 */

PROCEDURE GET_DEFAULTS (p_def_char OUT NOCOPY VARCHAR2,  /*Added the nocopy check for 4537865 */
            p_def_num OUT NOCOPY  NUMBER,  /*Added the nocopy check for 4537865 */
                        p_def_date OUT NOCOPY DATE,  /*Added the nocopy check for 4537865 */
                        p_return_status OUT NOCOPY VARCHAR2,  /*Added the nocopy check for 4537865 */
                        p_msg_count     OUT NOCOPY NUMBER,  /*Added the nocopy check for 4537865 */
                        p_msg_data   OUT NOCOPY VARCHAR2);  /*Added the nocopy check for 4537865 */

PROCEDURE Get_Accum_Period_Info
    ( p_api_version_number      IN  NUMBER,
      p_project_id          IN  NUMBER,
      p_last_accum_period       OUT  NOCOPY   VARCHAR2,  /*Added the nocopy check for 4537865 */
      p_last_accum_start_date   OUT NOCOPY DATE,  /*Added the nocopy check for 4537865 */
      p_last_accum_end_date     OUT NOCOPY DATE,  /*Added the nocopy check for 4537865 */
      p_current_reporting_period    OUT NOCOPY VARCHAR2,  /*Added the nocopy check for 4537865 */
      p_current_period_start_date   OUT NOCOPY DATE,  /*Added the nocopy check for 4537865 */
      p_current_period_end_date OUT NOCOPY DATE,  /*Added the nocopy check for 4537865 */
          p_return_status       OUT NOCOPY    VARCHAR2,  /*Added the nocopy check for 4537865 */
          p_msg_count           OUT NOCOPY    NUMBER,  /*Added the nocopy check for 4537865 */
          p_msg_data            OUT NOCOPY    VARCHAR2);  /*Added the nocopy check for 4537865 */

PROCEDURE Get_Release_info (
     p_current_release           OUT NOCOPY  VARCHAR2,  /*Added the nocopy check for 4537865 */
          p_return_status     OUT NOCOPY   VARCHAR2,  /*Added the nocopy check for 4537865 */
          p_msg_count         OUT NOCOPY   NUMBER,  /*Added the nocopy check for 4537865 */
          p_msg_data          OUT NOCOPY   VARCHAR2 );  /*Added the nocopy check for 4537865 */

TYPE pa_pm_message_amg_rec IS Record
(p_old_message_code  VARCHAR2(50),
 p_new_message_code  VARCHAR2(50),
 p_msg_context       VARCHAR2(10));
TYPE pa_pm_message_amg IS TABLE OF pa_pm_message_amg_rec
INDEX BY BINARY_INTEGER;
pa_pm_message_amg_tbl pa_pm_message_amg;

FUNCTION get_new_message_code
( p_message_code     IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_context      IN VARCHAR2 := FND_API.G_FALSE
) RETURN VARCHAR2;

PROCEDURE create_amg_mapping_msg;

PROCEDURE map_new_amg_msg
( p_old_message_code    IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_attribute       IN VARCHAR2 := FND_API.G_FALSE
 ,p_resize_flag         IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_context         IN VARCHAR2 := FND_API.G_FALSE
 ,p_attribute1       IN VARCHAR2 := FND_API.G_FALSE
 ,p_attribute2       IN VARCHAR2 := FND_API.G_FALSE
 ,p_attribute3       IN VARCHAR2 := FND_API.G_FALSE
 ,p_attribute4       IN VARCHAR2 := FND_API.G_FALSE
 ,p_attribute5       IN VARCHAR2 := FND_API.G_FALSE
);

FUNCTION get_task_number_amg
( p_task_number      IN VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_task_reference   IN VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_task_id          IN VARCHAR2 := FND_API.G_MISS_CHAR
) RETURN VARCHAR2;


END PA_INTERFACE_UTILS_PUB;

 

/
