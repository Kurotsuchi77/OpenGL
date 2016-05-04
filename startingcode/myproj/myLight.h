#include <string>
#include <GL/glew.h>

class myLight
{
public:
	GLfloat position[4];
	GLfloat color[4];
	GLfloat direction[4];
	GLfloat type; // 1 (point), 2 (directional), 3 (spot)
};