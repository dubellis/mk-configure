#include <stdio.h>
#include <string.h>

#include <mkc_strlcpy.h>
#include <mkc_strlcat.h>
#include <mkc_getline.h>

int main (int argc, char ** argv)
{
	char *buf = NULL;
	size_t size = 0;
	ssize_t len = 0;
	char small_buf [15];

	while (len = getline (&buf, &size, stdin), len != -1){
		len = strlen (buf);
		if (len > 0 && buf [len-1] == '\n')
			buf [len-1] = 0;

		strlcpy (small_buf, "foo17", sizeof (small_buf));
		strlcat (small_buf, buf, sizeof (small_buf));
		puts (small_buf);
	}

	return 0;
}
