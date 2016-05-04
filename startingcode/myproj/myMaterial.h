#include <string>
#include <GL/glew.h>

class myMaterial
{
public:
	GLfloat material_Ka[4]; //ambient color
	GLfloat material_Kd[4]; //diffuse color
	GLfloat material_Ks[4]; //specular color
	GLfloat material_Sh; //shininess coefficient
	std::string material_name; //name of the material
	std::string texture_name;

	myMaterial() {
		for (int i = 0; i < 4 ; ++i) {
			material_Ka[i] = 0;
			material_Ks[i] = 0;
			material_Kd[i] = 1;
		}
		material_Sh = 0;
	}
};