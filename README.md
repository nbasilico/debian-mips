# MIPS assembly in Debian
*The following tutorial is an advanced annex to the laboratory course of Computer Architecture II, given in the Computer Science B. Sc. program at the University of Milan. The work is the result of a joint idea and work with dr. Jacopo Essenziale who helped me in bringing this tutorial from a coffee-break discussion to an actual playground for students to enjoy. We are constantly searching for new ideas and suggestions. If you have any comments or would like to contribute feel free to contact us.*

Nicola Basilico nicola.basilico@unimi.it, Jacopo Essenziale jacopo.essenziale@unimi.it, Alessandro Clerici alessandro.clericilorenzini@studenti.unimi.it




## Motivation and scope
A great number of Computer Architecture courses adopt the MIPS architecture as a subject of study due to its simplicity and pragmatism. Such courses often include lab sessions where students are trained to develop Assembly programs. So do we in the course of Computer Architecture II at the University of Milan. Just like many of these lab courses around the world, we run our Assembly programs in a simulated environment using great tools like [Spim](http://spimsimulator.sourceforge.net/) or [Mars](http://courses.missouristate.edu/KenVollmar/MARS/). From one side, this approach tremendously simplifies the task of teaching Assembly to first-year students and is, undoubtedly, a lot of fun. On the other side, a simulator is not the real thing. The objective of this tutorial is to provide a step-by-step guide to setup a MIPS virtual machine and install Linux Debian on it. By doing so, we will enable the possibility to run Assembly sources without any fancy abstraction on the machine and by exploiting the development tools and library of a real operative system.




## Guides
- [Debian installation in a Qemu MIPS VM](guides/install.md)
- [What to look for in the manual](guides/manual.md)
- [Linux MIPS assembly quick-start](guides/quick-start.md)
- [Using the C library in assembly](guides/libc.md)
- [Crossbuild for MIPS on your system](guides/crossbuild.md)

### Other
- [Resources](resources.md)
- [Todo](todo.md)
- [Useful tools](tools.md)
