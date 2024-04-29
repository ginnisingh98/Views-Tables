--------------------------------------------------------
--  DDL for Package FND_IMP_DEPENDENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IMP_DEPENDENCY_PKG" AUTHID CURRENT_USER as
/* $Header: afimpdeps.pls 120.2 2005/11/02 10:22:02 ravmohan noship $ */

PROCEDURE INSERT_DEP_OBJECT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_object_id           OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,
  p_snapshot_id         IN      fnd_imp_depobjects.snapshot_id%TYPE,
  p_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_object_version_number OUT NOCOPY   fnd_imp_depobjects.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
);

PROCEDURE INSERT_DEP_RELATION(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_parent_object_id      OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,
  p_child_object_id       OUT NOCOPY     fnd_imp_depobjects.object_id%TYPE,

  p_snapshot_id           IN      fnd_imp_depobjects.snapshot_id%TYPE,
  p_dependency_type       IN      fnd_imp_deprelations.dependency_type%TYPE,

  p_parent_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_parent_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_parent_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_parent_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_parent_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_parent_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_parent_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_parent_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_parent_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_parent_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_parent_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_parent_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_parent_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_parent_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_parent_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_parent_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_parent_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_parent_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_parent_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_child_object_name         IN      fnd_imp_depobjects.object_name%TYPE,
  p_child_object_type         IN      fnd_imp_depobjects.object_type%TYPE,
  p_child_app_short_name      IN      fnd_imp_depobjects.app_short_name%TYPE,
  p_child_file_directory      IN      fnd_imp_depobjects.file_directory%TYPE,
  p_child_filename            IN      fnd_imp_depobjects.filename%TYPE,
  p_child_file_type           IN      fnd_imp_depobjects.file_type%TYPE,
  p_child_rcs_id              IN      fnd_imp_depobjects.rcs_id%TYPE,
  p_child_ochksum             IN      fnd_imp_depobjects.ochksum%TYPE,
  p_child_fchksum             IN      fnd_imp_depobjects.fchksum%TYPE,
  p_child_attrib0             IN      fnd_imp_depobjects.attrib0%TYPE,
  p_child_attrib1             IN      fnd_imp_depobjects.attrib1%TYPE,
  p_child_attrib2             IN      fnd_imp_depobjects.attrib2%TYPE,
  p_child_attrib3             IN      fnd_imp_depobjects.attrib3%TYPE,
  p_child_attrib4             IN      fnd_imp_depobjects.attrib4%TYPE,
  p_child_attrib5             IN      fnd_imp_depobjects.attrib5%TYPE,
  p_child_attrib6             IN      fnd_imp_depobjects.attrib6%TYPE,
  p_child_attrib7             IN      fnd_imp_depobjects.attrib7%TYPE,
  p_child_attrib8             IN      fnd_imp_depobjects.attrib8%TYPE,
  p_child_attrib9             IN      fnd_imp_depobjects.attrib9%TYPE,

  p_object_version_number OUT NOCOPY   fnd_imp_deprelations.object_version_number%TYPE,

  x_return_status       OUT NOCOPY     VARCHAR2,
  x_msg_count           OUT NOCOPY     NUMBER,
  x_msg_data            OUT NOCOPY     VARCHAR2
);

END FND_IMP_DEPENDENCY_PKG;

 

/
