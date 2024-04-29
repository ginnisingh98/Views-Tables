--------------------------------------------------------
--  DDL for Package OKC_MRV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_MRV_UTIL" 
/*$Header: OKCMRVUS.pls 120.0.12010000.4 2013/08/15 15:44:24 serukull noship $*/
AUTHID CURRENT_USER AS
   PROCEDURE update_k_art_var (
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_blobdata        IN   BLOB,
      p_type            IN   VARCHAR2,
      p_commit          IN   VARCHAR2  DEFAULT FND_API.G_FALSE
   );

   FUNCTION get_k_art_var (
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_type            IN   VARCHAR2
   )
      RETURN BLOB;

   FUNCTION get_uda_attr_xml (
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_attr_group_id   IN   NUMBER
   )
      RETURN CLOB;

   PROCEDURE update_uda_attr_xml (
      p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_attr_group_id   IN   NUMBER,
      p_mode            IN VARCHAR2 DEFAULT 'NORMAL',
      p_locking_enabled IN VARCHAR2 DEFAULT 'N',
      x_return_status              OUT NOCOPY VARCHAR2,
      x_msg_count                  OUT NOCOPY NUMBER,
      x_msg_data                   OUT NOCOPY VARCHAR2
     );

PROCEDURE update_uda_attr_xml (
      p_cat_id          IN   NUMBER,
      p_variable_code   IN   VARCHAR2,
      p_attr_group_id   IN   NUMBER
   );


   PROCEDURE mrv_pre_process (docid IN NUMBER, doctype IN VARCHAR2);

   PROCEDURE checkdochasmrv (
      docid       IN              NUMBER,
      doctype     IN              VARCHAR2,
      dochasmrv   OUT NOCOPY      VARCHAR2
   );

   FUNCTION getattributegroupdispname (attrgroupid IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION gettemplatename (mrv_tmpl_code IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE copy_variable_uda_data (
      p_from_cat_id          IN   NUMBER,
      p_from_variable_code   IN   VARCHAR2,
      p_to_cat_id            IN   NUMBER,
      p_to_variable_code     IN   VARCHAR2,
      x_return_status        OUT  NOCOPY VARCHAR2,
      x_msg_count            OUT  NOCOPY NUMBER,
      x_msg_data             OUT  NOCOPY VARCHAR2
   );

   PROCEDURE Create_Association (
                p_api_version                   IN   NUMBER  := 1
              ,p_object_id                     IN   NUMBER DEFAULT NULL
              ,p_classification_code           IN   VARCHAR2
              ,p_data_level                    IN   VARCHAR2 DEFAULT NULL
              ,p_attr_group_id                 IN   NUMBER
              ,p_enabled_flag                  IN   VARCHAR2 DEFAULT 'Y'
              ,p_view_privilege_id             IN   NUMBER  DEFAULT NULL    --ignored for now
              ,p_edit_privilege_id             IN   NUMBER  DEFAULT NULL    --ignored for now
              ,p_init_msg_list                 IN   VARCHAR2   :=  fnd_api.g_FALSE
              ,p_commit                        IN   VARCHAR2   :=  fnd_api.g_FALSE
              ,x_association_id                OUT NOCOPY NUMBER
              ,x_return_status                 OUT NOCOPY VARCHAR2
              ,x_errorcode                     OUT NOCOPY NUMBER
              ,x_msg_count                     OUT NOCOPY NUMBER
              ,x_msg_data                      OUT NOCOPY VARCHAR2
        );
END okc_mrv_util;

/
